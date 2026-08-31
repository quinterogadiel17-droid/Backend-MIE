import bcrypt from 'bcryptjs';
import { pool } from '../config/db.js';
import { env } from '../config/env.js';

const roles = [['Administrador', 'Acceso total al sistema'], ['Coordinador', 'Gestión institucional'], ['Inspector', 'Registro de inspecciones'], ['Técnico', 'Ejecución de mantenimientos'], ['Rector', 'Consulta y aprobación']];
try {
  for (const [nombre, descripcion] of roles) await pool.execute('INSERT IGNORE INTO roles (nombre_rol, descripcion) VALUES (?, ?)', [nombre, descripcion]);
  const [[adminRole]] = await pool.execute("SELECT id_rol FROM roles WHERE nombre_rol = 'Administrador'");
  const [existing] = await pool.execute('SELECT id_usuario FROM usuarios WHERE email = ?', ['admin@mie.local']);
  if (!existing.length) { const hash = await bcrypt.hash('Cambiar123!', 12); await pool.execute('INSERT INTO usuarios (id_rol, tipo_documento, documento_id, nombres, apellidos, email, password_hash) VALUES (?, ?, ?, ?, ?, ?, ?)', [adminRole.id_rol, 'CC', 'ADMIN-001', 'Administrador', 'MIE', 'admin@mie.local', hash]); console.log('Usuario inicial: admin@mie.local / Cambiar123!'); }
  console.log('Semilla aplicada correctamente.');
} catch (error) { console.error(error.message); process.exitCode = 1; } finally { await pool.end(); }
