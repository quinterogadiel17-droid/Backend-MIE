import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { allowRoles } from '../middlewares/auth.js';
import { ApiError, asyncHandler } from '../utils/ApiError.js';

const router = Router();
router.use(allowRoles('Administrador'));
const select = 'u.id_usuario, u.tipo_documento, u.documento_id, u.nombres, u.apellidos, u.email, u.telefono, u.direccion, u.avatar_url, u.estado, u.id_institucion, u.fecha_creacion, r.nombre_rol, r.id_rol';
const dataSchema = z.object({
  tipo_documento: z.string().trim().min(1).max(30).optional(), documento_id: z.string().trim().min(3).max(30), nombres: z.string().trim().min(2).max(100), apellidos: z.string().trim().min(2).max(100),
  email: z.string().email().max(120), telefono: z.string().trim().max(20).nullable().optional(), id_institucion: z.coerce.number().int().positive().nullable().optional(),
  id_rol: z.coerce.number().int().positive(), estado: z.enum(['Activo', 'Inactivo']), password: z.string().min(8).max(128).optional(),
});
async function one(id) { const [rows] = await pool.execute(`SELECT ${select} FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol WHERE u.id_usuario = ?`, [id]); if (!rows[0]) throw new ApiError(404, 'Usuario no encontrado.'); return rows[0]; }

router.get('/', asyncHandler(async (req, res) => {
  const page = Math.max(1, Number(req.query.page) || 1); const pageSize = Math.min(100, Math.max(1, Number(req.query.pageSize) || 20));
  const term = String(req.query.busqueda || '').trim(); const role = Number(req.query.id_rol) || null;
  const conditions = []; const values = [];
  if (term) { conditions.push('(u.nombres LIKE ? OR u.apellidos LIKE ? OR u.email LIKE ? OR u.documento_id LIKE ?)'); values.push(...Array(4).fill(`%${term}%`)); }
  if (role) { conditions.push('u.id_rol = ?'); values.push(role); }
  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const [[count]] = await pool.execute(`SELECT COUNT(*) AS total FROM usuarios u ${where}`, values);
  const [rows] = await pool.execute(`SELECT ${select} FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol ${where} ORDER BY u.id_usuario DESC LIMIT ? OFFSET ?`, [...values, pageSize, (page - 1) * pageSize]);
  res.json({ data: rows, total: count.total, page, pageSize });
}));
router.get('/roles', asyncHandler(async (_req, res) => { const [rows] = await pool.query('SELECT id_rol, nombre_rol, descripcion FROM roles ORDER BY nombre_rol'); res.json({ data: rows }); }));
router.post('/', asyncHandler(async (req, res) => { const data = dataSchema.extend({ password: z.string().min(8).max(128) }).parse(req.body); const [result] = await pool.execute('INSERT INTO usuarios (id_rol, id_institucion, tipo_documento, documento_id, nombres, apellidos, email, password_hash, telefono, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [data.id_rol, data.id_institucion || null, data.tipo_documento || 'CC', data.documento_id, data.nombres, data.apellidos, data.email, await bcrypt.hash(data.password, 12), data.telefono || null, data.estado]); res.status(201).json({ data: await one(result.insertId) }); }));
router.put('/:id', asyncHandler(async (req, res) => { const data = dataSchema.parse(req.body); const updates = [data.id_rol, data.id_institucion || null, data.tipo_documento || 'CC', data.documento_id, data.nombres, data.apellidos, data.email, data.telefono || null, data.estado]; let sql = 'UPDATE usuarios SET id_rol=?, id_institucion=?, tipo_documento=?, documento_id=?, nombres=?, apellidos=?, email=?, telefono=?, estado=?'; if (data.password) { sql += ', password_hash=?'; updates.push(await bcrypt.hash(data.password, 12)); } sql += ' WHERE id_usuario=?'; updates.push(req.params.id); const [result] = await pool.execute(sql, updates); if (!result.affectedRows) throw new ApiError(404, 'Usuario no encontrado.'); res.json({ data: await one(req.params.id) }); }));
router.patch('/:id/status', asyncHandler(async (req, res) => { const { estado } = z.object({ estado: z.enum(['Activo', 'Inactivo']) }).parse(req.body); if (Number(req.params.id) === req.user.sub && estado === 'Inactivo') throw new ApiError(400, 'No puedes bloquear tu propia cuenta.'); const [result] = await pool.execute('UPDATE usuarios SET estado = ? WHERE id_usuario = ?', [estado, req.params.id]); if (!result.affectedRows) throw new ApiError(404, 'Usuario no encontrado.'); res.json({ data: await one(req.params.id) }); }));

export default router;
