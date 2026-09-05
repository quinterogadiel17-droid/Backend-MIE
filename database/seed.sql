-- =============================================================================
-- SEMILLA: Datos iniciales para MIE
-- Ejecutar DESPUÉS de schema.sql sobre la base `mie_db`.
-- Los IDs fijos coinciden con el mapeo que usa el frontend
-- (prioridades 1-4, estados 1-6, categorías 1-3, tipos de mantenimiento 1-2, rol Administrador = 1).
-- =============================================================================
USE mie_db;

-- 1. ROLES ------------------------------------------------------------------
INSERT INTO roles (id_rol, nombre_rol, descripcion) VALUES
(1, 'Administrador', 'Acceso total al sistema'),
(2, 'Coordinador',  'Gestión institucional'),
(3, 'Inspector',    'Registro de inspecciones'),
(4, 'Técnico',      'Ejecución de mantenimientos'),
(5, 'Rector',       'Consulta y aprobación');

-- 2. INSTITUCIÓN Y SEDE (necesarias para crear espacios) --------------------
INSERT INTO instituciones
  (id_institucion, nombre_institucion, codigo_nit_rut, direccion, ciudad, departamento)
VALUES
  (1, 'Inst. Educativo San Martín', 'SAN-MARTIN-001', 'Av. Principal 100', 'Ciudad', 'Departamento');

INSERT INTO sedes (id_sede, id_institucion, nombre_sede, direccion, ciudad)
VALUES (1, 1, 'Sede Principal', 'Av. Principal 100', 'Ciudad');

-- 3. CATEGORÍAS DE ACTIVOS ---------------------------------------------------
INSERT INTO categorias_activos (id_categoria, nombre_categoria, descripcion) VALUES
(1, 'Mobiliario',       'Muebles y mobiliario institucional'),
(2, 'Equipos',          'Equipos tecnológicos y de apoyo'),
(3, 'Infraestructura',  'Elementos de infraestructura física');

-- 4. PRIORIDADES DE TICKETS ---------------------------------------------------
INSERT INTO prioridades_ticket (id_prioridad, nombre_prioridad, tiempo_respuesta_horas, descripcion) VALUES
(1, 'Baja',    48, 'Sin urgencia: se agenda normalmente'),
(2, 'Media',   24, 'Requiere atención en el día'),
(3, 'Alta',     8, 'Atención prioritaria'),
(4, 'Urgente',  2, 'Atención inmediata');

-- 5. TIPOS DE MANTENIMIENTO -----------------------------------------------------
INSERT INTO tipos_mantenimiento (id_tipo_mantenimiento, nombre_tipo, descripcion) VALUES
(1, 'Correctivo',  'Reparación por falla o deterioro'),
(2, 'Preventivo',  'Mantenimiento programado para evitar fallas');

-- 6. ESTADOS DE TICKETS -------------------------------------------------------
INSERT INTO estados_ticket (id_estado, nombre_estado) VALUES
(1, 'Abierto'),
(2, 'Asignado'),
(3, 'En Proceso'),
(4, 'Resuelto'),
(5, 'Cerrado'),
(6, 'Cancelado');

-- 7. USUARIO ADMINISTRADOR (admin@mie.local / Cambiar123!) --------------------
-- El hash bcrypt está precalculado; solo se inserta si no existe ya.
INSERT INTO usuarios (id_rol, tipo_documento, documento_id, nombres, apellidos, email, password_hash)
SELECT 1, 'CC', 'ADMIN-001', 'Administrador', 'MIE', 'admin@mie.local',
       '$2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE email = 'admin@mie.local');