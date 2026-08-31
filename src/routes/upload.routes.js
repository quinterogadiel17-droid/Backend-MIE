import { Router } from 'express';
import { mkdir, unlink, writeFile } from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import { z } from 'zod';
import { ApiError, asyncHandler } from '../utils/ApiError.js';

const router = Router();
const uploadsDir = path.join(process.cwd(), 'storage', 'uploads');
const mimeExtensions = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp', 'image/gif': 'gif' };

router.post('/', asyncHandler(async (req, res) => {
  const { dataUrl } = z.object({ dataUrl: z.string().min(32).max(7_000_000) }).parse(req.body);
  const match = /^data:(image\/(?:jpeg|png|webp|gif));base64,([A-Za-z0-9+/=]+)$/.exec(dataUrl);
  if (!match) throw new ApiError(400, 'Solo se aceptan imágenes JPG, PNG, WEBP o GIF válidas.');
  const buffer = Buffer.from(match[2], 'base64');
  if (!buffer.length || buffer.length > 5 * 1024 * 1024) throw new ApiError(400, 'La imagen debe pesar como máximo 5 MB.');
  await mkdir(uploadsDir, { recursive: true });
  const name = `${crypto.randomUUID()}.${mimeExtensions[match[1]]}`;
  await writeFile(path.join(uploadsDir, name), buffer, { flag: 'wx' });
  res.status(201).json({ url: `/uploads/${name}` });
}));

router.delete('/:name', asyncHandler(async (req, res) => {
  const name = path.basename(req.params.name);
  if (name !== req.params.name || !/^[a-f0-9-]+\.(jpg|png|webp|gif)$/.test(name)) throw new ApiError(400, 'Archivo inválido.');
  try { await unlink(path.join(uploadsDir, name)); } catch (error) { if (error.code !== 'ENOENT') throw error; }
  res.status(204).send();
}));

export default router;
