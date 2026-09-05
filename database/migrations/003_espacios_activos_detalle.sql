-- =============================================================================
-- MIGRACIÓN 003: Detalle físico de espacios y activos
-- Ejecutar una sola vez sobre instalaciones creadas con migraciones 001/002.
-- Agrega a pisos_espacios y activos los campos que utiliza el frontend para
-- mostrar tipo, código, área, capacidad y estado sin datos quemados.
-- =============================================================================

ALTER TABLE pisos_espacios
  ADD COLUMN codigo_espacio VARCHAR(50) NULL AFTER bloque_seccion,
  ADD COLUMN tipo_espacio VARCHAR(60) NULL AFTER codigo_espacio,
  ADD COLUMN area_m2 DECIMAL(8,2) NOT NULL DEFAULT 0 AFTER tipo_espacio,
  ADD COLUMN capacidad INT NOT NULL DEFAULT 0 AFTER area_m2,
  ADD COLUMN estado_espacio ENUM('Excelente', 'Bueno', 'Regular', 'Malo', 'Crítico') NOT NULL DEFAULT 'Bueno' AFTER capacidad,
  ADD COLUMN url_foto VARCHAR(255) NULL AFTER estado_espacio;

ALTER TABLE activos
  ADD COLUMN cantidad INT NOT NULL DEFAULT 1 AFTER nombre_activo,
  ADD COLUMN valor_estimado DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER nivel_riesgo,
  ADD COLUMN fecha_adquisicion DATE NULL AFTER valor_estimado,
  ADD COLUMN url_foto VARCHAR(255) NULL AFTER fecha_adquisicion;