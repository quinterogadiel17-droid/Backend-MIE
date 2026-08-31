import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { ApiError, asyncHandler } from '../utils/ApiError.js';

const router = Router();
const moderatorRoles = ['Administrador', 'Coordinador'];

router.get('/', asyncHandler(async (req, res) => {
  const [rows] = await pool.execute('SELECT id_notificacion AS id, titulo, mensaje AS descripcion, tipo_alerta AS tipo, leido, fecha_envio AS fecha FROM notificaciones WHERE id_usuario_destino = ? ORDER BY fecha_envio DESC LIMIT 50', [req.user.sub]);
  res.json({ data: rows });
}));

router.patch('/:id/read', asyncHandler(async (req, res) => {
  const [result] = await pool.execute('UPDATE notificaciones SET leido = TRUE WHERE id_notificacion = ? AND id_usuario_destino = ?', [req.params.id, req.user.sub]);
  if (!result.affectedRows) throw new ApiError(404, 'Notificación no encontrada.');
  res.status(204).send();
}));

router.patch('/read-all', asyncHandler(async (req, res) => {
  await pool.execute('UPDATE notificaciones SET leido = TRUE WHERE id_usuario_destino = ? AND leido = FALSE', [req.user.sub]);
  res.status(204).send();
}));

router.post('/moderator', asyncHandler(async (req, res) => {
  const { mensaje } = z.object({ mensaje: z.string().trim().min(5).max(1000) }).parse(req.body);
  const [senders] = await pool.execute('SELECT nombres, apellidos FROM usuarios WHERE id_usuario = ?', [req.user.sub]);
  const name = senders[0] ? `${senders[0].nombres} ${senders[0].apellidos}` : 'Un usuario';
  const [moderators] = await pool.query(`SELECT u.id_usuario FROM usuarios u JOIN roles r ON r.id_rol = u.id_rol WHERE u.estado = 'Activo' AND r.nombre_rol IN (${moderatorRoles.map(() => '?').join(',')})`, moderatorRoles);
  if (!moderators.length) throw new ApiError(409, 'No hay moderadores activos para recibir el aviso.');
  await pool.query('INSERT INTO notificaciones (id_usuario_destino, titulo, mensaje, tipo_alerta) VALUES ?', [moderators.map((u) => [u.id_usuario, 'Aviso para moderación', `${name}: ${mensaje}`, 'Advertencia'])]);
  res.status(201).json({ message: 'Aviso enviado a moderación.' });
}));

export default router;
