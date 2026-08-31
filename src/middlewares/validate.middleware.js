import { ApiError } from '../utils/api-error.js';
export const validate = (schema) => (req, _res, next) => { const parsed = schema.safeParse(req.body); if (!parsed.success) return next(new ApiError(422, 'Datos de entrada inválidos', parsed.error.flatten().fieldErrors)); req.body = parsed.data; next(); };
