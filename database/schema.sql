-- =============================================================================
-- BASE DE DATOS: MIE (Plataforma de Monitoreo de Infraestructura Educacional)
-- Script para MySQL / MariaDB compatible con MySQL Workbench (Reverse Engineer)
-- =============================================================================

DROP DATABASE IF EXISTS mie_db;
CREATE DATABASE mie_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mie_db;

-- -----------------------------------------------------------------------------
-- 1. MÓDULO DE USUARIOS Y ROLES (Administrador, Inspector, Técnico, Coordinador/Rector)
-- -----------------------------------------------------------------------------

CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE instituciones (
    id_institucion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_institucion VARCHAR(150) NOT NULL,
    codigo_nit_rut VARCHAR(30) NOT NULL UNIQUE,
    direccion VARCHAR(200) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NULL,
    email_contacto VARCHAR(100) NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    id_institucion INT NULL,
    tipo_documento VARCHAR(30) NOT NULL DEFAULT 'CC',
    documento_id VARCHAR(30) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NULL,
    direccion VARCHAR(200) NULL,
    avatar_url VARCHAR(255) NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso DATETIME NULL,
    CONSTRAINT fk_usuarios_roles FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usuarios_instituciones FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tokens_recuperacion (
    id_token INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    fecha_expiracion DATETIME NOT NULL,
    usado BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_tokens_usuarios FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. MÓDULO DE INFRAESTRUCTURA Y SEDES
-- -----------------------------------------------------------------------------

CREATE TABLE sedes (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    id_institucion INT NOT NULL,
    nombre_sede VARCHAR(150) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    persona_contacto VARCHAR(150) NULL,
    telefono_contacto VARCHAR(20) NULL,
    CONSTRAINT fk_sedes_instituciones FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pisos_espacios (
    id_piso INT AUTO_INCREMENT PRIMARY KEY,
    id_sede INT NOT NULL,
    numero_piso INT NOT NULL,
    bloque_seccion VARCHAR(100) NOT NULL,
    codigo_espacio VARCHAR(50) NULL,
    tipo_espacio VARCHAR(60) NULL,
    area_m2 DECIMAL(8,2) NOT NULL DEFAULT 0,
    capacidad INT NOT NULL DEFAULT 0,
    estado_espacio ENUM('Excelente', 'Bueno', 'Regular', 'Malo', 'Crítico') NOT NULL DEFAULT 'Bueno',
    url_foto VARCHAR(255) NULL,
    fecha_ultima_inspeccion DATE NULL,
    descripcion_ubicacion VARCHAR(255) NULL,
    CONSTRAINT fk_pisos_sedes FOREIGN KEY (id_sede) REFERENCES sedes(id_sede) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. MÓDULO DE ACTIVOS (Mobiliario, Equipos, Infraestructura)
-- -----------------------------------------------------------------------------

CREATE TABLE categorias_activos (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria ENUM('Mobiliario', 'Equipos', 'Infraestructura') NOT NULL UNIQUE,
    descripcion TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE activos (
    id_activo INT AUTO_INCREMENT PRIMARY KEY,
    id_piso INT NOT NULL,
    id_categoria INT NOT NULL,
    codigo_inventario VARCHAR(50) NOT NULL UNIQUE,
    nombre_activo VARCHAR(150) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    descripcion TEXT NULL,
    marca VARCHAR(100) NULL,
    modelo VARCHAR(100) NULL,
    numero_serie VARCHAR(100) NULL,
    estado_activo ENUM('Excelente', 'Bueno', 'Regular', 'Malo', 'Crítico') DEFAULT 'Bueno',
    nivel_riesgo ENUM('Bajo', 'Medio', 'Alto', 'Crítico') DEFAULT 'Bajo',
    estado_operativo ENUM('Activo', 'En Mantenimiento', 'Dado de Baja') DEFAULT 'Activo',
    valor_estimado DECIMAL(12,2) NOT NULL DEFAULT 0,
    fecha_adquisicion DATE NULL,
    url_foto VARCHAR(255) NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_baja DATETIME NULL,
    motivo_baja TEXT NULL,
    CONSTRAINT fk_activos_pisos FOREIGN KEY (id_piso) REFERENCES pisos_espacios(id_piso) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_activos_categorias FOREIGN KEY (id_categoria) REFERENCES categorias_activos(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. MÓDULO DE INSPECCIONES Y EVALUACIÓN DE DAÑOS
-- -----------------------------------------------------------------------------

CREATE TABLE inspecciones (
    id_inspeccion INT AUTO_INCREMENT PRIMARY KEY,
    id_inspector INT NOT NULL,
    id_activo INT NOT NULL,
    fecha_inspeccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    ubicacion_exacta VARCHAR(255) NOT NULL,
    estado_evaluado ENUM('Excelente', 'Bueno', 'Regular', 'Malo', 'Crítico') NOT NULL,
    nivel_riesgo_calificado ENUM('Bajo', 'Medio', 'Alto', 'Crítico') NOT NULL,
    observaciones TEXT NULL,
    ticket_generado_auto BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_inspecciones_inspector FOREIGN KEY (id_inspector) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inspecciones_activo FOREIGN KEY (id_activo) REFERENCES activos(id_activo) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE registro_danos (
    id_dano INT AUTO_INCREMENT PRIMARY KEY,
    id_inspeccion INT NOT NULL,
    tipo_dano VARCHAR(100) NOT NULL,
    descripcion_dano TEXT NOT NULL,
    nivel_severidad ENUM('Leve', 'Moderado', 'Grave', 'Severo') NOT NULL,
    CONSTRAINT fk_danos_inspeccion FOREIGN KEY (id_inspeccion) REFERENCES inspecciones(id_inspeccion) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE evidencias_fotograficas_inspeccion (
    id_fotografia INT AUTO_INCREMENT PRIMARY KEY,
    id_inspeccion INT NOT NULL,
    id_dano INT NULL,
    url_fotografia VARCHAR(255) NOT NULL,
    descripcion_foto VARCHAR(255) NULL,
    fecha_captura DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fotos_inspeccion FOREIGN KEY (id_inspeccion) REFERENCES inspecciones(id_inspeccion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fotos_dano FOREIGN KEY (id_dano) REFERENCES registro_danos(id_dano) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. MÓDULO DE TICKETS E INCIDENTES
-- -----------------------------------------------------------------------------

CREATE TABLE prioridades_ticket (
    id_prioridad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_prioridad ENUM('Baja', 'Media', 'Alta', 'Urgente') NOT NULL UNIQUE,
    tiempo_respuesta_horas INT NOT NULL,
    descripcion VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE estados_ticket (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado ENUM('Abierto', 'Asignado', 'En Proceso', 'Resuelto', 'Cerrado', 'Cancelado') NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE tickets (
    id_ticket INT AUTO_INCREMENT PRIMARY KEY,
    id_inspeccion INT NULL,
    id_activo INT NOT NULL,
    id_prioridad INT NOT NULL,
    id_estado INT NOT NULL,
    id_usuario_creador INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion_incidente TEXT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME NULL,
    CONSTRAINT fk_tickets_inspeccion FOREIGN KEY (id_inspeccion) REFERENCES inspecciones(id_inspeccion) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_tickets_activo FOREIGN KEY (id_activo) REFERENCES activos(id_activo) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tickets_prioridad FOREIGN KEY (id_prioridad) REFERENCES prioridades_ticket(id_prioridad) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tickets_estado FOREIGN KEY (id_estado) REFERENCES estados_ticket(id_estado) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tickets_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE asignaciones_tickets (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_ticket INT NOT NULL,
    id_tecnico INT NOT NULL,
    id_asignador INT NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado_aceptacion ENUM('Pendiente', 'Aceptado', 'Rechazado') DEFAULT 'Pendiente',
    fecha_respuesta DATETIME NULL,
    motivo_rechazo TEXT NULL,
    CONSTRAINT fk_asig_ticket FOREIGN KEY (id_ticket) REFERENCES tickets(id_ticket) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_asig_tecnico FOREIGN KEY (id_tecnico) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_asig_asignador FOREIGN KEY (id_asignador) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. MÓDULO DE MANTENIMIENTOS
-- -----------------------------------------------------------------------------

CREATE TABLE tipos_mantenimiento (
    id_tipo_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo ENUM('Correctivo', 'Preventivo') NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE mantenimientos (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_ticket INT NULL,
    id_activo INT NOT NULL,
    id_tecnico INT NOT NULL,
    id_tipo_mantenimiento INT NOT NULL,
    costo_estimado DECIMAL(12,2) NOT NULL DEFAULT 0,
    id_coordinador_aprobador INT NULL,
    fecha_programada DATETIME NOT NULL,
    fecha_inicio DATETIME NULL,
    fecha_fin DATETIME NULL,
    horas_trabajadas DECIMAL(5,2) DEFAULT 0.00,
    estado_mantenimiento ENUM('Programado', 'En Proceso', 'Pendiente Aprobacion', 'Aprobado', 'Rechazado', 'Completado') DEFAULT 'Programado',
    resumen_trabajo TEXT NULL,
    fecha_aprobacion DATETIME NULL,
    CONSTRAINT fk_mant_ticket FOREIGN KEY (id_ticket) REFERENCES tickets(id_ticket) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_mant_activo FOREIGN KEY (id_activo) REFERENCES activos(id_activo) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_mant_tecnico FOREIGN KEY (id_tecnico) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_mant_tipo FOREIGN KEY (id_tipo_mantenimiento) REFERENCES tipos_mantenimiento(id_tipo_mantenimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_mant_aprobador FOREIGN KEY (id_coordinador_aprobador) REFERENCES usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE materiales_mantenimiento (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    id_mantenimiento INT NOT NULL,
    nombre_material VARCHAR(150) NOT NULL,
    cantidad DECIMAL(8,2) NOT NULL,
    unidad_medida VARCHAR(30) NOT NULL,
    costo_unitario DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT fk_mat_mantenimiento FOREIGN KEY (id_mantenimiento) REFERENCES mantenimientos(id_mantenimiento) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE solicitudes_repuestos (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_mantenimiento INT NOT NULL,
    id_tecnico_solicitante INT NOT NULL,
    repuesto_solicitado VARCHAR(150) NOT NULL,
    cantidad INT NOT NULL,
    justificacion TEXT NOT NULL,
    estado_solicitud ENUM('Solicitado', 'En Revision', 'Aprobado', 'Rechazado', 'Entregado') DEFAULT 'Solicitado',
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rep_mantenimiento FOREIGN KEY (id_mantenimiento) REFERENCES mantenimientos(id_mantenimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rep_tecnico FOREIGN KEY (id_tecnico_solicitante) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE evidencias_mantenimiento (
    id_evidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_mantenimiento INT NOT NULL,
    url_evidencia VARCHAR(255) NOT NULL,
    fase ENUM('Antes', 'Durante', 'Despues') NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evid_mantenimiento FOREIGN KEY (id_mantenimiento) REFERENCES mantenimientos(id_mantenimiento) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. MÓDULO DE NOTIFICACIONES, ALERTAS Y CONFIGURACIÓN DEL SISTEMA
-- -----------------------------------------------------------------------------

CREATE TABLE notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_destino INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo_alerta ENUM('Info', 'Advertencia', 'Critico') DEFAULT 'Info',
    leido BOOLEAN DEFAULT FALSE,
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario_destino) REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE parametros_sistema (
    id_parametro INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. MÓDULO DE REPORTES, INDICADORES (KPIs) Y SALUD INSTITUCIONAL
-- -----------------------------------------------------------------------------

CREATE TABLE indicadores_kpi (
    id_kpi INT AUTO_INCREMENT PRIMARY KEY,
    id_institucion INT NOT NULL,
    id_sede INT NULL,
    nombre_indicador VARCHAR(150) NOT NULL,
    valor_calculado DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(30) NOT NULL,
    fecha_calculo DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kpi_institucion FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_kpi_sede FOREIGN KEY (id_sede) REFERENCES sedes(id_sede) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE indice_salud_institucional (
    id_indice INT AUTO_INCREMENT PRIMARY KEY,
    id_institucion INT NOT NULL,
    id_sede INT NULL,
    puntaje_salud DECIMAL(5,2) NOT NULL, -- Ej: 85.50 / 100
    nivel_salud ENUM('Excelente', 'Aceptable', 'En Riesgo', 'Crítico') NOT NULL,
    factores_evaluados JSON NULL,
    fecha_evaluacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_salud_institucion FOREIGN KEY (id_institucion) REFERENCES instituciones(id_institucion) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_salud_sede FOREIGN KEY (id_sede) REFERENCES sedes(id_sede) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reportes_generados (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_generador INT NOT NULL,
    titulo_reporte VARCHAR(150) NOT NULL,
    tipo_reporte ENUM('Mantenimiento', 'Inspección', 'Incidentes', 'General', 'Indicadores') NOT NULL,
    formato_exportacion ENUM('PDF', 'Excel', 'Compartido') NOT NULL,
    url_archivo VARCHAR(255) NULL,
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rep_usuario FOREIGN KEY (id_usuario_generador) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE comparticion_reportes (
    id_comparticion INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte INT NOT NULL,
    id_usuario_destino INT NOT NULL,
    fecha_compartido DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comp_reporte FOREIGN KEY (id_reporte) REFERENCES reportes_generados(id_reporte) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_comp_usuario FOREIGN KEY (id_usuario_destino) REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE respaldos_sistema (
    id_respaldo INT AUTO_INCREMENT PRIMARY KEY,
    fecha_respaldo DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_respaldo ENUM('Automático', 'Manual') DEFAULT 'Automático',
    url_respaldo VARCHAR(255) NOT NULL,
    tamano_mb DECIMAL(10,2) NOT NULL,
    estado ENUM('Exitoso', 'Fallido') DEFAULT 'Exitoso'
) ENGINE=InnoDB;





