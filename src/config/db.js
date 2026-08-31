import mysql from 'mysql2/promise';
import { env } from './env.js';

export const pool = mysql.createPool({ ...env.db, waitForConnections: true, connectionLimit: 10, queueLimit: 0, timezone: 'Z' });

export async function verifyDatabase() {
  const connection = await pool.getConnection();
  try { await connection.ping(); } finally { connection.release(); }
}
