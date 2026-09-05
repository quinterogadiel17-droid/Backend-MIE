-- Migración 004: campos extras para formularios (billete COP, inspección y costos de mantenimiento).
ALTER TABLE pisos_espacios ADD COLUMN fecha_ultima_inspeccion DATE NULL AFTER url_foto;
ALTER TABLE mantenimientos ADD COLUMN costo_estimado DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER id_tecnico;