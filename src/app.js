import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import path from "node:path";
import authRoutes from "./routes/auth.routes.js";
import resourceRoutes from "./routes/resources.routes.js";
import dashboardRoutes from "./routes/dashboard.routes.js";
import profileRoutes from "./routes/profile.routes.js";
import uploadRoutes from "./routes/upload.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import adminUserRoutes from "./routes/admin-users.routes.js";
import { authenticate } from "./middlewares/auth.js";
import { env } from "./config/env.js";
import { errorHandler, notFound } from "./middlewares/errors.js";
const app = express();
app.disable("x-powered-by");
app.use(helmet());
app.use(
  cors({
    origin: env.frontendUrl,
    methods: ["GET", "POST", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);
app.use(express.json({ limit: "8mb" }));
app.use('/uploads', express.static(path.join(process.cwd(), 'storage', 'uploads'), { fallthrough: false, maxAge: '7d' }));
app.use(
  "/api/auth",
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 10,
    standardHeaders: "draft-8",
    legacyHeaders: false,
  }),
  authRoutes,
);
app.use(
  "/api",
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: "draft-8",
    legacyHeaders: false,
  }),
);
app.get("/api/health", (_req, res) => res.json({ status: "ok" }));
app.use("/api/dashboard", authenticate, dashboardRoutes);
app.use("/api/profile", authenticate, profileRoutes);
app.use("/api/uploads", authenticate, uploadRoutes);
app.use("/api/notifications", authenticate, notificationRoutes);
app.use("/api/admin/users", authenticate, adminUserRoutes);
app.use("/api", authenticate, resourceRoutes);
app.use(notFound);
app.use(errorHandler);
export default app;
