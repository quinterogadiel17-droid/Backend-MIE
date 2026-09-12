import { Router } from 'express';
import { pool } from '../config/db.js';
import { asyncHandler } from '../utils/ApiError.js';

const router = Router();

router.get('/users', asyncHandler(async (req, res) => {
  const role = Number(req.query.id_rol) || null;
  const conditions = ['u.estado = ?'];
  const values = ['Activo'];
  if (role) { conditions.push('u.id_rol = ?'); values.push(role); }
  const where = conditions.join(' AND ');
  const [rows] = await pool.query(
    `SELECT u.id_usuario, u.nombres, u.apellidos, u.email, r.nombre_rol, u.id_rol
     FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol
     WHERE ${where} ORDER BY u.nombres, u.apellidos`,
    values,
  );
  res.json({ data: rows });
}));

export default router;