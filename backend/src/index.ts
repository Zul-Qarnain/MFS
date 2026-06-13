import { createApp } from './app.js';
import { env } from './config/env.js';
import { disconnectPrisma } from './config/prisma.js';
import { disconnectRedis } from './config/redis.js';
import { logger } from './utils/logger.js';

const app = createApp();

const server = app.listen(env.PORT, env.HOST, () => {
  logger.info(`[mfs-backend] listening on http://${env.HOST}:${env.PORT}`);
});

const shutdown = (signal: string) => {
  logger.info(`Received ${signal}, shutting down`);
  server.close(() => {
    void (async () => {
      await disconnectPrisma();
      await disconnectRedis();
      process.exit(0);
    })();
  });

  setTimeout(() => process.exit(1), 10_000).unref();
};

process.on('SIGINT', () => void shutdown('SIGINT'));
process.on('SIGTERM', () => void shutdown('SIGTERM'));
process.on('unhandledRejection', (reason) => {
  logger.error({ reason }, 'unhandledRejection');
});
process.on('uncaughtException', (err) => {
  logger.error({ err }, 'uncaughtException');
  process.exit(1);
});
