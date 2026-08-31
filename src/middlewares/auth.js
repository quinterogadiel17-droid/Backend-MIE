import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { ApiError } from '../utils/ApiError.js';

export function authenticate(req, _res, next) {
  const value = req.headers.authorization;
  if (!value?.startsWith('Bearer ')) return next(new ApiError(401, 'Token de acceso requerido.'));
  try { req.user = jwt.verify(value.slice(7), env.jwtSecret); next(); }
  catch { next(new ApiError(401, 'Token inválido o vencido.')); }
}

export const allowRoles = (...roles) => (req, _res, next) =>
  roles.includes(req.user.rol) ? next() : next(new ApiError(403, 'No tienes permisos para esta operación.'));
