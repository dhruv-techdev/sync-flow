import IORedis, { type Redis } from "ioredis";
import { logger } from "~/lib/logger/logger.server";

declare global {
  // eslint-disable-next-line no-var
  var __redis: Redis | undefined;
}

const DEFAULT_REDIS_URL = "redis://127.0.0.1:6379";

function createConnection(): Redis {
  // Don't throw at import time: a missing URL must still let routes like the
  // health check load and report "unhealthy" rather than crash the process.
  const url = process.env.REDIS_URL;
  if (!url) {
    logger.error(
      "REDIS_URL is not set; falling back to " + DEFAULT_REDIS_URL,
    );
  }

  const conn = new IORedis(url ?? DEFAULT_REDIS_URL, {
    maxRetriesPerRequest: null, // required by BullMQ
    enableReadyCheck: true,
    lazyConnect: false,
  });

  conn.on("connect", () => logger.info("Redis connecting"));
  conn.on("ready", () => logger.info("Redis ready"));
  conn.on("error", (err) => logger.error({ err }, "Redis error"));
  conn.on("close", () => logger.warn("Redis connection closed"));
  conn.on("reconnecting", () => logger.warn("Redis reconnecting"));

  return conn;
}

export const redis: Redis = global.__redis ?? createConnection();
if (process.env.NODE_ENV !== "production") global.__redis = redis;

export async function pingRedis(): Promise<boolean> {
  try {
    const pong = await redis.ping();
    return pong === "PONG";
  } catch {
    return false;
  }
}
