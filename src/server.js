import { env } from './config/env.js';
import { verifyDatabase, pool } from './config/db.js';
import app from './app.js';

async function runMigrations() {
  try {
    await pool.execute(`ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS tipo_documento VARCHAR(30) NOT NULL DEFAULT 'CC' AFTER id_institucion`);
    console.log('Migración tipo_documento aplicada');
  } catch (error) {
    if (!error.message.includes('Duplicate column')) {
      console.error('Error en migración:', error.message);
    }
  }
}

app.get('/api/health', async (_req, res, next) => { try { await verifyDatabase(); res.json({ status: 'ok' }); } catch (error) { next(error); } });

await runMigrations();
app.listen(env.port, () => console.log(`API MIE disponible en http://localhost:${env.port}/api`));
