import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import { env } from './config/env';
import { checkDbConnection } from './config/db';
import { connectRedis } from './config/redis';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './middleware/logger';
import healthRoutes from './modules/health/health.routes';

const app = express();

// ─── Security & parsing middleware ───────────────────────────────
app.use(helmet());
app.use(
  cors({
    origin: env.ALLOWED_ORIGINS.split(','),
    credentials: true,
  }),
);
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(logger);

// ─── Rate limiting ───────────────────────────────────────────────
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use(globalLimiter);

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { success: false, message: 'Too many auth attempts, please try again later.' },
});

// ─── Routes ──────────────────────────────────────────────────────
app.use('/health', healthRoutes);

// Registered as modules are built in subsequent issues:
// app.use('/api/auth',     authLimiter, authRoutes);
// app.use('/api/menu',     menuRoutes);
// app.use('/api/tables',   tableRoutes);
// app.use('/api/orders',   orderRoutes);
// app.use('/api/payments', paymentRoutes);
// app.use('/api/kitchen',  kitchenRoutes);
// app.use('/api/admin',    adminRoutes);

// ─── 404 handler ─────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ success: false, code: 'NOT_FOUND', message: 'Route not found' });
});

// ─── Global error handler ────────────────────────────────────────
app.use(errorHandler);

// ─── Startup ─────────────────────────────────────────────────────
async function bootstrap() {
  try {
    await checkDbConnection();
    await connectRedis();

    const PORT = parseInt(env.PORT, 10);
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`   Environment: ${env.NODE_ENV}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

bootstrap();

export default app;
