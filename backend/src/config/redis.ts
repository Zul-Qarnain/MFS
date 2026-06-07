import Redis from 'ioredis';

import { env } from './env.js';

let redis: Redis | undefined;

export function getRedis(): Redis {
  if (redis) return redis;

  redis = new Redis(env.REDIS_URL, {
    maxRetriesPerRequest: 3,
    enableReadyCheck: true,
    lazyConnect: true,
  });

  redis.on('error', (err) => {
    // eslint-disable-next-line no-console
    console.error('[redis] error', err.message);
  });

  return redis;
}

export async function disconnectRedis(): Promise<void> {
  await redis?.quit();
  redis = undefined;
}
