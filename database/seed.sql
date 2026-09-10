-- =============================================================================
-- SEMILLA: Datos iniciales para MIE
-- Ejecutar DESPUÉS de schema.sql sobre la base `mie_db`.
-- Los IDs fijos coinciden con el mapeo que usa el frontend
-- (prioridades 1-4, estados 1-6, categorías 1-3, tipos de mantenimiento 1-2).
-- Jerarquía de roles: administrador > rector > coordinador > supervisor > tecnico
-- =============================================================================
USE mie_db;

-- 1. ROLES ------------------------------------------------------------------
-- ID fijos para que el frontend pueda referenciarlos directamente
INSERT INTO roles (id_rol, nombre_rol, descripcion) VALUES
(1, 'Administrador', 'Acceso total al sistema - gestión de usuarios, configuración, reportes'),
(2, 'Rector',        'Consulta y aprobación - visión general, reportes, aprobación de mantenimientos'),
(3, 'Coordinador',   'Gestión institucional - espacios, activos, mantenimientos, asignación de tickets'),
(4, 'Supervisor',    'Registro de inspecciones - evaluaciones, checklist, evidencias (Inspector en BD)'),
(5, 'Tecnico',       'Ejecución de mantenimientos - OT, materiales, evidencias de trabajo');

-- 2. INSTITUCIÓN Y SEDE (necesarias para crear espacios) --------------------
INSERT INTO instituciones
  (id_institucion, nombre_institucion, codigo_nit_rut, direccion, ciudad, departamento, total_pisos, total_aulas, capacidad_maxima, porcentaje_ocupacion_tipica)
VALUES
  (1, 'Inst. Educativo San Martín', 'SAN-MARTIN-001', 'Av. Principal 100', 'Ciudad', 'Departamento', 3, 8, 250, 65.00);

INSERT INTO sedes (id_sede, id_institucion, nombre_sede, direccion, ciudad)
VALUES (1, 1, 'Sede Principal', 'Av. Principal 100', 'Ciudad');

-- 3. PISOS/ESPACIOS DE EJEMPLO (para validar pisos reales) ------------------
INSERT INTO pisos_espacios (id_piso, id_sede, numero_piso, bloque_seccion, codigo_espacio, tipo_espacio, area_m2, capacidad, estado_espacio)
VALUES
(1, 1, 1, 'Bloque A', 'A-101', 'Aula', 60.00, 35, 'Bueno'),
(2, 1, 1, 'Bloque A', 'A-102', 'Aula', 55.00, 30, 'Bueno'),
(3, 1, 1, 'Bloque A', 'A-103', 'Laboratorio', 80.00, 25, 'Excelente'),
(4, 1, 2, 'Bloque B', 'B-201', 'Aula', 65.00, 38, 'Regular'),
(5, 1, 2, 'Bloque B', 'B-202', 'Aula', 60.00, 35, 'Bueno'),
(6, 1, 2, 'Bloque B', 'B-203', 'Común', 120.00, 80, 'Bueno'),
(7, 1, 3, 'Bloque C', 'C-301', 'Administrativo', 40.00, 10, 'Excelente'),
(8, 1, 3, 'Bloque C', 'C-302', 'Servicios', 30.00, 5, 'Bueno');

-- 4. CATEGORÍAS DE ACTIVOS ---------------------------------------------------
INSERT INTO categorias_activos (id_categoria, nombre_categoria, descripcion) VALUES
(1, 'Mobiliario',       'Muebles y mobiliario institucional'),
(2, 'Equipos',          'Equipos tecnológicos y de apoyo'),
(3, 'Infraestructura',  'Elementos de infraestructura física');

-- 5. PRIORIDADES DE TICKETS ---------------------------------------------------
INSERT INTO prioridades_ticket (id_prioridad, nombre_prioridad, tiempo_respuesta_horas, descripcion) VALUES
(1, 'Baja',    48, 'Sin urgencia: se agenda normalmente'),
(2, 'Media',   24, 'Requiere atención en el día'),
(3, 'Alta',     8, 'Atención prioritaria'),
(4, 'Urgente',  2, 'Atención inmediata');

-- 6. ESTADOS DE TICKETS -------------------------------------------------------
INSERT INTO estados_ticket (id_estado, nombre_estado) VALUES
(1, 'Abierto'),
(2, 'Asignado'),
(3, 'En Proceso'),
(4, 'Resuelto'),
(5, 'Cerrado'),
(6, 'Cancelado');

-- 7. TIPOS DE MANTENIMIENTO ----------------------------------------------------
INSERT INTO tipos_mantenimiento (id_tipo_mantenimiento, nombre_tipo, descripcion) VALUES
(1, 'Correctivo',  'Reparación por falla o deterioro'),
(2, 'Preventivo',  'Mantenimiento programado para evitar fallas');

-- 8. ESTADOS DE MANTENIMIENTO (se usan como ENUM en la tabla) -----------------
-- Valores: 'Programado', 'En Proceso', 'Pendiente Aprobacion', 'Aprobado', 'Rechazado', 'Completado'

-- 9. USUARIO ADMINISTRADOR (admin@mie.local / Cambiar123!) --------------------
-- Hash bcrypt generado con costo 12 para la contraseña "Cambiar123!"
-- $2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a
INSERT INTO usuarios (id_rol, id_institucion, tipo_documento, documento_id, nombres, apellidos, email, password_hash, estado)
SELECT 1, 1, 'CC', 'ADMIN-001', 'Administrador', 'MIE', 'admin@mie.local',
       '$2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a',
       'Activo'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE email = 'admin@mie.local');

-- 10. USUARIOS DE PRUEBA PARA CADA ROL ---------------------------------------
-- Contraseña para todos: "Cambiar123!" (mismo hash)
INSERT INTO usuarios (id_rol, id_institucion, tipo_documento, documento_id, nombres, apellidos, email, password_hash, estado)
VALUES
-- Rector
(2, 1, 'CC', 'RECTOR-001', 'María', 'González', 'rector@mie.local', '$2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a', 'Activo'),
-- Coordinador
(3, 1, 'CC', 'COORD-001', 'Carlos', 'Rodríguez', 'coordinador@mie.local', '$2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a', 'Activo'),
-- Supervisor (Inspector)
(4, 1, 'CC', 'INSP-001', 'Patricia', 'Núñez', 'inspector@mie.local', '$2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a', 'Activo'),
-- Técnico
(5, 1, 'CC', 'TEC-001', 'Juan', 'Pérez', 'tecnico@mie.local', '$2b$12$9EGYXmPjiZYfiXxbv4YAl.oyoD.jgUfOeUBf5e0ZlgL5au5mrYc1a', 'Activo');

-- 11. ACTIVOS DE EJEMPLO -----------------------------------------------------
INSERT INTO activos (id_activo, id_piso, id_categoria, codigo_inventario, nombre_activo, cantidad, estado_activo, valor_estimado, fecha_adquisicion)
VALUES
(1, 1, 1, 'A-101-MOB-001', 'Escritorio docente', 1, 'Bueno', 450000.00, '2023-02-15'),
(2, 1, 1, 'A-101-MOB-002', 'Silla estudiante', 35, 'Bueno', 120000.00, '2023-02-15'),
(3, 1, 2, 'A-101-EQP-001', 'Proyector Epson EB-X06', 1, 'Excelente', 2800000.00, '2023-03-10'),
(4, 2, 1, 'A-102-MOB-001', 'Escritorio docente', 1, 'Regular', 450000.00, '2022-08-20'),
(5, 2, 1, 'A-102-MOB-002', 'Silla estudiante', 30, 'Bueno', 120000.00, '2022-08-20'),
(6, 3, 2, 'A-103-EQP-001', 'Computador HP ProDesk', 25, 'Excelente', 3500000.00, '2024-01-15'),
(7, 3, 3, 'A-103-INF-001', 'Mesa laboratorio', 5, 'Bueno', 1800000.00, '2023-06-01'),
(8, 4, 1, 'B-201-MOB-001', 'Silla estudiante', 38, 'Regular', 120000.00, '2022-03-10');

-- 12. PARÁMETROS DEL SISTEMA --------------------------------------------------
INSERT INTO parametros_sistema (clave, valor, descripcion) VALUES
('institucion_nombre', 'Inst. Educativo San Martín', 'Nombre de la institución para reportes'),
('institucion_ciclo_actual', '2026', 'Ciclo académico actual'),
('umbral_alerta_espacios_criticos', '10', 'Porcentaje de espacios críticos para alerta'),
('umbral_alerta_activos_sin_revisar', '20', 'Porcentaje de activos sin revisar para alerta'),
('dias_alerta_mantenimiento_vencido', '7', 'Días antes de vencimiento para alertar');

-- 13. INDICADORES KPI INICIALES -----------------------------------------------
INSERT INTO indicadores_kpi (id_institucion, id_sede, nombre_indicador, valor_calculado, unidad_medida)
VALUES
(1, 1, 'Espacios en buen estado', 75.00, '%'),
(1, 1, 'Activos operativos', 92.00, '%'),
(1, 1, 'OT completadas a tiempo', 88.00, '%'),
(1, 1, 'Índice de salud institucional', 85.50, '/100');

-- 14. ÍNDICE DE SALUD INSTITUCIONAL INICIAL -----------------------------------
INSERT INTO indice_salud_institucional (id_institucion, id_sede, puntaje_salud, nivel_salud, factores_evaluados)
VALUES
(1, 1, 85.50, 'Aceptable', '{"espacios": 75, "activos": 92, "mantenimiento": 88, "inspecciones": 82}');

-- 15. INSPECCIONES DE EJEMPLO -------------------------------------------------
INSERT INTO inspecciones (id_inspeccion, id_inspector, id_activo, fecha_inspeccion, ubicacion_exacta, estado_evaluado, nivel_riesgo_calificado, observaciones)
VALUES
(1, 4, 1, '2024-01-15 10:00:00', 'Aula A-101 - Escritorio docente', 'Bueno', 'Bajo', 'Buen estado general'),
(2, 4, 3, '2024-01-16 11:00:00', 'Aula A-101 - Proyector', 'Excelente', 'Bajo', 'Funcionamiento óptimo'),
(3, 4, 4, '2024-01-17 09:30:00', 'Aula A-102 - Escritorio docente', 'Regular', 'Medio', 'Rayones en superficie');

-- 16. EVIDENCIAS FOTOGRÁFICAS DE INSPECCIÓN (ejemplo) -------------------------
-- INSERT INTO evidencias_fotograficas_inspeccion (id_inspeccion, url_fotografia, descripcion_foto)
-- VALUES (1, 'https://ejemplo.com/evidencia1.jpg', 'Vista general del escritorio');

-- 17. TICKETS DE EJEMPLO ------------------------------------------------------
INSERT INTO tickets (id_ticket, id_inspeccion, id_activo, id_prioridad, id_estado, id_usuario_creador, titulo, descripcion_incidente, fecha_creacion)
VALUES
(1, 3, 4, 2, 2, 3, 'Reparar escritorio rayado', 'El escritorio del docente en A-102 presenta rayones profundos', '2024-01-18 08:00:00'),
(2, NULL, 2, 3, 1, 3, 'Revisar sillas A-101', 'Algunas sillas presentan tornillos sueltos', '2024-01-19 09:00:00');

-- 18. ASIGNACIONES DE TICKETS -------------------------------------------------
INSERT INTO asignaciones_tickets (id_asignacion, id_ticket, id_tecnico, id_asignador, estado_aceptacion, fecha_respuesta)
VALUES
(1, 1, 5, 3, 'Aceptado', '2024-01-18 10:00:00');

-- 19. MANTENIMIENTOS DE EJEMPLO -----------------------------------------------
INSERT INTO mantenimientos (id_mantenimiento, id_ticket, id_activo, id_tecnico, id_tipo_mantenimiento, costo_estimado, id_coordinador_aprobador, fecha_programada, estado_mantenimiento)
VALUES
(1, 1, 4, 5, 1, 150000.00, 3, '2024-01-20 08:00:00', 'Programado');

-- 20. MATERIALES DE MANTENIMIENTO ---------------------------------------------
INSERT INTO materiales_mantenimiento (id_mantenimiento, nombre_material, cantidad, unidad_medida, costo_unitario)
VALUES
(1, 'Lija fina', 2, 'Unidad', 5000.00),
(1, 'Barniz transparente', 1, 'Litro', 25000.00),
(1, 'Paño microfibra', 3, 'Unidad', 3000.00);

-- 21. EVIDENCIAS DE MANTENIMIENTO (ejemplo) -----------------------------------
-- INSERT INTO evidencias_mantenimiento (id_mantenimiento, url_evidencia, fase, descripcion)
-- VALUES (1, 'https://ejemplo.com/antes.jpg', 'Antes', 'Estado previo al mantenimiento');

-- 22. NOTIFICACIONES DE EJEMPLO -----------------------------------------------
INSERT INTO notificaciones (id_usuario_destino, titulo, mensaje, tipo_alerta, leido)
VALUES
(1, 'Bienvenido a MIE', 'Sistema inicializado correctamente. Configura tu institución y sedes.', 'Info', TRUE),
(1, 'Espacios sin inspección', 'Hay 3 espacios sin inspección en los últimos 30 días.', 'Advertencia', FALSE),
(1, 'Mantenimiento vencido', 'El mantenimiento #1 está vencido desde hace 2 días.', 'Critico', FALSE);

-- =============================================================================
-- FIN DEL SCRIPT DE SEMILLA
-- =============================================================================