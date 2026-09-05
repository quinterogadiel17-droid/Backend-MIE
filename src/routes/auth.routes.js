import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'node:crypto';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { env } from '../config/env.js';
import { ApiError, asyncHandler } from '../utils/ApiError.js';
import { authenticate } from '../middlewares/auth.js';

const router = Router();
const loginSchema = z.object({ email: z.string().email(), password: z.string().min(8), recordarme: z.boolean().optional() });
const publicUser = 'u.id_usuario, u.tipo_documento, u.documento_id, u.nombres, u.apellidos, u.email, u.telefono, u.estado, u.id_institucion, u.avatar_url, r.nombre_rol';

router.post('/login', asyncHandler(async (req, res) => {
  const { email, password, recordarme } = loginSchema.parse(req.body);
  const [rows] = await pool.execute(`SELECT ${publicUser}, u.password_hash FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol WHERE u.email = ? LIMIT 1`, [email]);
  const user = rows[0];
  if (!user || user.estado !== 'Activo' || !(await bcrypt.compare(password, user.password_hash))) throw new ApiError(401, 'Credenciales inválidas.');
  await pool.execute('UPDATE usuarios SET ultimo_acceso = NOW() WHERE id_usuario = ?', [user.id_usuario]);
  delete user.password_hash;
  const token = jwt.sign({ sub: user.id_usuario, email: user.email, rol: user.nombre_rol }, env.jwtSecret, { expiresIn: recordarme ? '30d' : env.jwtExpiresIn });
  res.json({ token, usuario: user });
}));

router.get('/me', authenticate, asyncHandler(async (req, res) => {
  const [rows] = await pool.execute(`SELECT ${publicUser} FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol WHERE u.id_usuario = ?`, [req.user.sub]);
  if (!rows[0]) throw new ApiError(404, 'Usuario no encontrado.');
  res.json({ usuario: rows[0] });
}));

router.post('/forgot-password', asyncHandler(async (req, res) => {
  const { email } = z.object({ email: z.string().email() }).parse(req.body);
  const [users] = await pool.execute('SELECT id_usuario FROM usuarios WHERE email = ? AND estado = \'Activo\'', [email]);
  if (users[0]) { const token = crypto.randomBytes(32).toString('hex'); await pool.execute('INSERT INTO tokens_recuperacion (id_usuario, token, fecha_expiracion) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))', [users[0].id_usuario, token]); }
  res.json({ message: 'Si el correo existe, se generó una solicitud de recuperación.' });
}));

router.post('/reset-password', asyncHandler(async (req, res) => {
  const { token, password } = z.object({ token: z.string().min(32), password: z.string().min(8) }).parse(req.body);
  const [tokens] = await pool.execute('SELECT id_token, id_usuario FROM tokens_recuperacion WHERE token = ? AND usado = FALSE AND fecha_expiracion > NOW() LIMIT 1', [token]);
  if (!tokens[0]) throw new ApiError(400, 'Token de recuperación inválido o vencido.');
  await pool.execute('UPDATE usuarios SET password_hash = ? WHERE id_usuario = ?', [await bcrypt.hash(password, 12), tokens[0].id_usuario]);
  await pool.execute('UPDATE tokens_recuperacion SET usado = TRUE WHERE id_token = ?', [tokens[0].id_token]);
  res.json({ message: 'Contraseña actualizada.' });
}));

export default router;
