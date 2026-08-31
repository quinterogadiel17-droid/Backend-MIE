// Solo estos nombres pueden terminar en una consulta SQL. No se usa entrada de usuario como identificador.
export const resources = {
  roles: { pk: 'id_rol', adminOnly: true }, instituciones: { pk: 'id_institucion' }, usuarios: { pk: 'id_usuario', adminOnly: true, sensitive: true },
  tokens_recuperacion: { pk: 'id_token', adminOnly: true }, sedes: { pk: 'id_sede' }, pisos_espacios: { pk: 'id_piso' },
  categorias_activos: { pk: 'id_categoria', adminOnly: true }, activos: { pk: 'id_activo' }, inspecciones: { pk: 'id_inspeccion' }, registro_danos: { pk: 'id_dano' }, evidencias_fotograficas_inspeccion: { pk: 'id_fotografia' },
  prioridades_ticket: { pk: 'id_prioridad', adminOnly: true }, estados_ticket: { pk: 'id_estado', adminOnly: true }, tickets: { pk: 'id_ticket' }, asignaciones_tickets: { pk: 'id_asignacion' },
  tipos_mantenimiento: { pk: 'id_tipo_mantenimiento', adminOnly: true }, mantenimientos: { pk: 'id_mantenimiento' }, materiales_mantenimiento: { pk: 'id_material' }, solicitudes_repuestos: { pk: 'id_solicitud' }, evidencias_mantenimiento: { pk: 'id_evidencia' },
  notificaciones: { pk: 'id_notificacion' }, parametros_sistema: { pk: 'id_parametro', adminOnly: true }, indicadores_kpi: { pk: 'id_kpi' }, indice_salud_institucional: { pk: 'id_indice' }, reportes_generados: { pk: 'id_reporte' }, comparticion_reportes: { pk: 'id_comparticion' }, respaldos_sistema: { pk: 'id_respaldo', adminOnly: true }
};
