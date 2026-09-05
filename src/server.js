import { env } from './config/env.js';
import { verifyDatabase, pool } from './config/db.js';
import app from './app.js';

async function runMigrations() {
  async function columnExists(table, column) {
    const [rows] = await pool.query(
      `SELECT COUNT(*) AS n FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?`,
      [table, column],
    );
    return Number(rows[0].n) > 0;
  }
  try {
    if (!(await columnExists('usuarios', 'tipo_documento'))) {
      await pool.execute(`ALTER TABLE usuarios ADD COLUMN tipo_documento VARCHAR(30) NOT NULL DEFAULT 'CC' AFTER id_institucion`);
      console.log('Migración tipo_documento aplicada');
    }
    if (!(await columnExists('pisos_espacios', 'fecha_ultima_inspeccion'))) {
      await pool.execute(`ALTER TABLE pisos_espacios ADD COLUMN fecha_ultima_inspeccion DATE NULL AFTER url_foto`);
      console.log('Migración fecha_ultima_inspeccion aplicada');
    }
    if (!(await columnExists('mantenimientos', 'costo_estimado'))) {
      await pool.execute(`ALTER TABLE mantenimientos ADD COLUMN costo_estimado DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER id_tecnico`);
      console.log('Migración costo_estimado aplicada');
    }
  } catch (error) {
    console.error('Error en migración:', error.message);
  }
}

app.get('/api/health', async (_req, res, next) => { try { await verifyDatabase(); res.json({ status: 'ok' }); } catch (error) { next(error); } });

await runMigrations();
app.listen(env.port, () => console.log(`API MIE disponible en http://localhost:${env.port}/api`));
