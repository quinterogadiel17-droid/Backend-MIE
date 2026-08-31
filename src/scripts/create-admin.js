import "dotenv/config";
import bcrypt from "bcryptjs";
import { pool } from "../config/db.js";

const [
  email,
  password,
  documento = "ADMIN-001",
  nombres = "Administrador",
  apellidos = "MIE",
  tipoDocumento = "CC",
] = process.argv.slice(2);
if (!email || !password) {
  console.error(
    "Uso: node src/scripts/create-admin.js correo@dominio.com contraseña [documento] [nombres] [apellidos] [tipoDocumento]",
  );
  process.exit(1);
}
const [roles] = await pool.execute(
  "SELECT id_rol FROM roles WHERE nombre_rol = 'Administrador' LIMIT 1",
);
if (!roles[0]) {
  console.error("Primero inserta el rol 'Administrador' en la tabla roles.");
  process.exit(1);
}
await pool.execute(
  "INSERT INTO usuarios (id_rol, tipo_documento, documento_id, nombres, apellidos, email, password_hash) VALUES (?, ?, ?, ?, ?, ?, ?)",
  [
    roles[0].id_rol,
    tipoDocumento,
    documento,
    nombres,
    apellidos,
    email,
    await bcrypt.hash(password, 12),
  ],
);
console.log("Administrador creado.");
await pool.end();
