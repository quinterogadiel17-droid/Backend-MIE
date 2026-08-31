# Backend MIE

API REST para la plataforma MIE, separada del frontend. Usa Node.js, Express, MySQL2 y JWT.

## Inicio rápido

1. Copia `.env.example` a `.env` y completa las credenciales MySQL y un `JWT_SECRET` largo.
2. Ejecuta el esquema: `mysql -u root -p < database/schema.sql`.
3. Inserta los roles iniciales, por ejemplo: `INSERT INTO roles (nombre_rol) VALUES ('Administrador'), ('Inspector'), ('Técnico'), ('Coordinador');`.
4. Crea el primer administrador: `node src/scripts/create-admin.js admin@mie.local UnaClaveSegura123`.
5. Inicia: `npm run dev`.

El frontend puede usar `VITE_API_URL=http://localhost:8080`.

## Rutas

- `POST /auth/login` — `{ "email", "password" }`.
- `GET /auth/me` — requiere `Authorization: Bearer <token>`.
- `POST /auth/forgot-password` y `POST /auth/reset-password`.
- `GET|POST /:recurso`, `GET|PUT|DELETE /:recurso/:id` — requieren JWT.
- `GET /health` — comprueba conexión con MySQL.

`recurso` corresponde a las tablas del esquema (por ejemplo, `activos`, `tickets`, `mantenimientos`, `inspecciones` o `sedes`). Los catálogos y usuarios requieren rol Administrador. Las operaciones usan consultas parametrizadas y una lista cerrada de recursos; nunca se interpolan identificadores enviados por el cliente.

## Seguridad incluida

JWT con expiración, hash bcrypt (12 rondas), cabeceras Helmet, CORS configurable, límites de tasa generales y más estrictos para autenticación, validación de payload y manejo consistente de errores. No subas `.env` al repositorio.
