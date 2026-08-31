-- Agregar campo tipo_documento a la tabla usuarios
ALTER TABLE usuarios ADD COLUMN tipo_documento VARCHAR(30) NOT NULL DEFAULT 'CC' AFTER id_institucion;