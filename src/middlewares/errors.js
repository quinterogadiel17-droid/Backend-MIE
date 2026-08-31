export function notFound(req, _res, next) { const error = new Error(`Ruta no encontrada: ${req.method} ${req.originalUrl}`); error.status = 404; next(error); }
export function errorHandler(error, _req, res, _next) {
  const status = error.status || (error.code === 'ER_DUP_ENTRY' ? 409 : error.name === 'ZodError' ? 400 : 500);
  if (status >= 500) console.error(error);
  res.status(status).json({ error: { message: error.message || 'Error interno del servidor.', details: error.details } });
}
