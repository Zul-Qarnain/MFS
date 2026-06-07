import { Router } from 'express';

import { env } from '../../config/env.js';
import { prisma } from '../../config/prisma.js';
import { getRedis } from '../../config/redis.js';

const router = Router();

router.get('/health', async (_req, res) => {
  const checks: Record<string, 'ok' | 'error'> = { db: 'ok', redis: 'ok' };

  try {
    await prisma.$queryRaw`SELECT 1`;
  } catch {
    checks.db = 'error';
  }

  try {
    await getRedis().ping();
  } catch {
    checks.redis = 'error';
  }

  const allOk = Object.values(checks).every((v) => v === 'ok');
  res.status(allOk ? 200 : 503).json({
    status: allOk ? 'ok' : 'degraded',
    env: env.NODE_ENV,
    timestamp: new Date().toISOString(),
    checks,
  });
});

router.get('/ready', (_req, res) => {
  res.status(200).json({ status: 'ready' });
});

export default router;
