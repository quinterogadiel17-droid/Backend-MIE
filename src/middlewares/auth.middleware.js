import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { ApiError } from '../utils/api-error.js';
export function authenticate(req, _res, next) { const h = req.headers.authorization; if (!h?.startsWith('Bearer ')) return next(new ApiError(401, 'Token de acceso requerido')); try { req.user = jwt.verify(h.slice(7), env.jwtSecret); next(); } catch { next(new ApiError(401, 'Token inválido o vencido')); } }
export const authorizeRoles = (...roles) => (req, _res, next) => roles.includes(req.user.rol) ? next() : next(new ApiError(403, 'No tiene permisos para realizar esta acción'));
export const canManage = authorizeRoles('Administrador', 'Coordinador', 'Rector');
