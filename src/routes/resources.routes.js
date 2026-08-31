import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { pool } from '../config/db.js';
import { resources } from '../resources.js';
import { ApiError, asyncHandler } from '../utils/ApiError.js';
import { allowRoles } from '../middlewares/auth.js';

const router = Router();
const columnCache = new Map();
const hidden = new Set(['password_hash']);

async function columnsFor(table) {
  if (!columnCache.has(table)) {
    const [columns] = await pool.query(`DESCRIBE \`${table}\``);
    columnCache.set(table, new Map(columns.map((column) => [column.Field, column])));
  }
  return columnCache.get(table);
}

async function payloadFor(req, table, config, isCreate) {
  if (!req.body || Array.isArray(req.body) || typeof req.body !== 'object') throw new ApiError(400, 'El cuerpo debe ser un objeto JSON.');
  const columns = await columnsFor(table);
  const data = { ...req.body };
  delete data[config.pk];
  for (const key of Object.keys(data)) if (!columns.has(key) || hidden.has(key) || key === 'fecha_creacion' || key === 'fecha_registro') throw new ApiError(400, `Campo no permitido: ${key}`);
  if (table === 'usuarios' && data.password !== undefined) { data.password_hash = await bcrypt.hash(String(data.password), 12); delete data.password; }
  if (table === 'usuarios' && isCreate && !data.password_hash) throw new ApiError(400, 'El campo password es obligatorio al crear un usuario.');
  if (table === 'usuarios' && !isCreate && data.password === '') delete data.password;
  if (!Object.keys(data).length) throw new ApiError(400, 'No hay campos válidos para guardar.');
  return data;
}

function configFor(req) { const config = resources[req.params.resource]; if (!config) throw new ApiError(404, 'Recurso no encontrado.'); return config; }
function selectColumns(config) { return config.sensitive ? '* ' : '*'; }

router.use('/:resource', (req, _res, next) => {
  try { const config = configFor(req); if (config.adminOnly) return allowRoles('Administrador')(req, _res, next); next(); } catch (error) { next(error); }
});

router.get('/:resource', asyncHandler(async (req, res) => {
  const config = configFor(req); const page = Math.max(1, Number(req.query.page) || 1); const pageSize = Math.min(100, Math.max(1, Number(req.query.pageSize) || 25));
  const columns = await columnsFor(req.params.resource);
  const filters = []; const values = [];
  for (const [key, value] of Object.entries(req.query)) {
    if (['page', 'pageSize', 'busqueda'].includes(key) || value === undefined || Array.isArray(value) || !columns.has(key)) continue;
    filters.push(`\`${key}\` = ?`); values.push(value);
  }
  const search = typeof req.query.busqueda === 'string' ? req.query.busqueda.trim() : '';
  if (search) {
    const searchable = [...columns.values()].filter((c) => /char|text/i.test(c.Type) && !hidden.has(c.Field)).map((c) => c.Field);
    if (searchable.length) { filters.push(`(${searchable.map((name) => `\`${name}\` LIKE ?`).join(' OR ')})`); values.push(...searchable.map(() => `%${search}%`)); }
  }
  const where = filters.length ? ` WHERE ${filters.join(' AND ')}` : '';
  const [countRows] = await pool.query(`SELECT COUNT(*) AS total FROM \`${req.params.resource}\`${where}`, values);
  const [rows] = await pool.query(`SELECT ${selectColumns(config)} FROM \`${req.params.resource}\`${where} ORDER BY \`${config.pk}\` DESC LIMIT ? OFFSET ?`, [...values, pageSize, (page - 1) * pageSize]);
  if (config.sensitive) rows.forEach((row) => delete row.password_hash);
  res.json({ data: rows, total: countRows[0].total, page, pageSize });
}));

router.get('/:resource/:id', asyncHandler(async (req, res) => {
  const config = configFor(req); const [rows] = await pool.execute(`SELECT ${selectColumns(config)} FROM \`${req.params.resource}\` WHERE \`${config.pk}\` = ?`, [req.params.id]);
  if (!rows[0]) throw new ApiError(404, 'Registro no encontrado.'); if (config.sensitive) delete rows[0].password_hash; res.json({ data: rows[0] });
}));

router.post('/:resource', asyncHandler(async (req, res) => {
  const config = configFor(req); const data = await payloadFor(req, req.params.resource, config, true); const keys = Object.keys(data);
  const [result] = await pool.execute(`INSERT INTO \`${req.params.resource}\` (${keys.map((key) => `\`${key}\``).join(', ')}) VALUES (${keys.map(() => '?').join(', ')})`, keys.map((key) => data[key]));
  const [rows] = await pool.execute(`SELECT ${selectColumns(config)} FROM \`${req.params.resource}\` WHERE \`${config.pk}\` = ?`, [result.insertId]); if (config.sensitive) delete rows[0].password_hash;
  res.status(201).json({ data: rows[0] });
}));

router.put('/:resource/:id', asyncHandler(async (req, res) => {
  const config = configFor(req); const data = await payloadFor(req, req.params.resource, config, false); const keys = Object.keys(data);
  const [result] = await pool.execute(`UPDATE \`${req.params.resource}\` SET ${keys.map((key) => `\`${key}\` = ?`).join(', ')} WHERE \`${config.pk}\` = ?`, [...keys.map((key) => data[key]), req.params.id]);
  if (!result.affectedRows) throw new ApiError(404, 'Registro no encontrado.'); const [rows] = await pool.execute(`SELECT ${selectColumns(config)} FROM \`${req.params.resource}\` WHERE \`${config.pk}\` = ?`, [req.params.id]); if (config.sensitive) delete rows[0].password_hash;
  res.json({ data: rows[0] });
}));

router.delete('/:resource/:id', asyncHandler(async (req, res) => {
  const config = configFor(req); const [result] = await pool.execute(`DELETE FROM \`${req.params.resource}\` WHERE \`${config.pk}\` = ?`, [req.params.id]);
  if (!result.affectedRows) throw new ApiError(404, 'Registro no encontrado.'); res.status(204).send();
}));

export default router;
