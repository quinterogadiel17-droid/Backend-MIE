-- Ejecutar una sola vez sobre instalaciones creadas antes de esta actualización.
-- Las rutas de imagen apuntan a storage/uploads del servidor, por lo que sobreviven
-- a reinicios mientras ese directorio se conserve como volumen persistente.
ALTER TABLE usuarios ADD COLUMN direccion VARCHAR(200) NULL AFTER telefono;
ALTER TABLE usuarios ADD COLUMN avatar_url VARCHAR(255) NULL AFTER direccion;
