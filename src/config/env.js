import 'dotenv/config';

const required = ['DB_HOST', 'DB_NAME', 'DB_USER', 'JWT_SECRET'];
if (process.env.NODE_ENV === 'production') {
  for (const key of required) if (!process.env[key]) throw new Error(`Falta la variable ${key}`);
}

export const env = {
  port: Number(process.env.PORT || 8080),
  nodeEnv: process.env.NODE_ENV || 'development',
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  frontendUrl: process.env.CORS_ORIGIN || 'http://localhost:5173',
  jwtSecret: process.env.JWT_SECRET || 'desarrollo-no-usar-en-produccion',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '8h',
  db: {
    host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 3306),
    database: process.env.DB_NAME || 'mie_db', user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || ''
  }
};
