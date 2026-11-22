import { Router, Request, Response } from 'express';
import { db } from '../../config/db';
import { redis } from '../../config/redis';

const router = Router();

router.get('/', async (_req: Request, res: Response) => {
  const health: Record<string, string> = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: `${Math.floor(process.uptime())}s`,
  };

  // Check PostgreSQL
  try {
    await db.query('SELECT 1');
    health.postgres = 'connected';
  } catch {
    health.postgres = 'error';
    health.status = 'degraded';
  }

  // Check Redis
  try {
    await redis.ping();
    health.redis = 'connected';
  } catch {
    health.redis = 'error';
    health.status = 'degraded';
  }

  const statusCode = health.status === 'ok' ? 200 : 503;
  res.status(statusCode).json(health);
});

export default router;
