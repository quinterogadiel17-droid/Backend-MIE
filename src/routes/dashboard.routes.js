import { Router } from 'express';
import { pool } from '../config/db.js';
import { asyncHandler } from '../utils/ApiError.js';

const router = Router();
router.get('/', asyncHandler(async (req, res) => {
  const [[[espacios]], [[activos]], [[sinRevisar]], [[abiertos]], [[urgentes]], [[salud]]] = await Promise.all([
    pool.query('SELECT COUNT(*) total FROM pisos_espacios'), pool.query('SELECT COUNT(*) total FROM activos'),
    pool.query('SELECT COUNT(*) total FROM activos WHERE estado_activo = \'Activo\' AND fecha_registro < DATE_SUB(NOW(), INTERVAL 6 MONTH)'),
    pool.query("SELECT COUNT(*) total FROM tickets t JOIN estados_ticket e ON e.id_estado=t.id_estado WHERE e.nombre_estado NOT IN ('Resuelto','Cerrado','Cancelado')"),
    pool.query("SELECT COUNT(*) total FROM tickets t JOIN prioridades_ticket p ON p.id_prioridad=t.id_prioridad WHERE p.nombre_prioridad='Urgente'"),
    pool.query('SELECT AVG(puntaje_salud) valor FROM indice_salud_institucional')
  ]);
  const [evolucion] = await pool.query("SELECT DATE_FORMAT(fecha_creacion, '%Y-%m') periodo, SUM(id_estado IN (SELECT id_estado FROM estados_ticket WHERE nombre_estado IN ('Resuelto','Cerrado'))) completadas, SUM(id_estado IN (SELECT id_estado FROM estados_ticket WHERE nombre_estado NOT IN ('Resuelto','Cerrado','Cancelado'))) pendientes FROM tickets WHERE fecha_creacion >= DATE_SUB(CURDATE(), INTERVAL 5 MONTH) GROUP BY periodo ORDER BY periodo");
  const [estados] = await pool.query('SELECT estado_activo nombre, COUNT(*) cantidad FROM activos GROUP BY estado_activo');
  const [presupuesto] = await pool.query("SELECT DATE_FORMAT(m.fecha_programada, '%Y-%m') mes, COALESCE(SUM(mm.cantidad * mm.costo_unitario), 0) valor FROM mantenimientos m LEFT JOIN materiales_mantenimiento mm ON mm.id_mantenimiento=m.id_mantenimiento WHERE m.fecha_programada >= DATE_SUB(CURDATE(), INTERVAL 5 MONTH) GROUP BY mes ORDER BY mes");
  const [notificaciones] = await pool.execute('SELECT id_notificacion id, titulo, mensaje descripcion, tipo_alerta tipo, leido, fecha_envio fecha FROM notificaciones WHERE id_usuario_destino = ? ORDER BY fecha_envio DESC LIMIT 4', [req.user.sub]);
  res.json({ kpis: { espaciosTotales: espacios.total, espaciosVariacion: 0, activosRegistrados: activos.total, activosNoRevisados: sinRevisar.total, ticketsAbiertos: abiertos.total, ticketsUrgentes: urgentes.total, indiceEstadoGlobal: Number(salud.valor || 0), indiceObjetivo: 85 }, evolucion: evolucion.map((x) => ({ mes: x.periodo, completadas: Number(x.completadas), pendientes: Number(x.pendientes) })), estadoEspacios: estados.map((x) => ({ name: x.nombre, value: Number(x.cantidad) })), presupuesto: presupuesto.map((x) => ({ mes: x.mes, valor: Number(x.valor) })), notificaciones });
}));
export default router;
