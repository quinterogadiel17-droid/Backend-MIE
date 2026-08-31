import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { ApiError, asyncHandler } from '../utils/ApiError.js';

const router = Router();
const fields = 'u.id_usuario, u.tipo_documento, u.documento_id, u.nombres, u.apellidos, u.email, u.telefono, u.direccion, u.avatar_url, u.estado, u.id_institucion, r.nombre_rol';
const profileSchema = z.object({
  nombres: z.string().trim().min(2).max(100), apellidos: z.string().trim().min(2).max(100),
  documento_id: z.string().trim().min(3).max(30), email: z.string().email().max(120),
  telefono: z.string().trim().max(20).nullable().optional(), direccion: z.string().trim().max(200).nullable().optional(),
  avatar_url: z.string().max(255).nullable().optional(),
});

async function getProfile(id) {
  const [rows] = await pool.execute(`SELECT ${fields} FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol WHERE u.id_usuario = ?`, [id]);
  if (!rows[0]) throw new ApiError(404, 'Usuario no encontrado.');
  return rows[0];
}

router.get('/me', asyncHandler(async (req, res) => res.json({ usuario: await getProfile(req.user.sub) })));

router.patch('/me', asyncHandler(async (req, res) => {
  const data = profileSchema.parse(req.body);
  await pool.execute('UPDATE usuarios SET nombres = ?, apellidos = ?, documento_id = ?, email = ?, telefono = ?, direccion = ?, avatar_url = ? WHERE id_usuario = ?', [
    data.nombres, data.apellidos, data.documento_id, data.email, data.telefono || null, data.direccion || null, data.avatar_url || null, req.user.sub,
  ]);
  res.json({ usuario: await getProfile(req.user.sub) });
}));

router.patch('/me/password', asyncHandler(async (req, res) => {
  const { passwordActual, passwordNueva } = z.object({ passwordActual: z.string().min(8), passwordNueva: z.string().min(8).max(128) }).parse(req.body);
  const [rows] = await pool.execute('SELECT password_hash FROM usuarios WHERE id_usuario = ?', [req.user.sub]);
  if (!rows[0] || !(await bcrypt.compare(passwordActual, rows[0].password_hash))) throw new ApiError(400, 'La contraseña actual no es correcta.');
  await pool.execute('UPDATE usuarios SET password_hash = ? WHERE id_usuario = ?', [await bcrypt.hash(passwordNueva, 12), req.user.sub]);
  res.json({ message: 'Contraseña actualizada.' });
}));

export default router;
