import { pingRedis } from "~/lib/redis/connection.server";
import { deadLetterQueue, retryQueue, syncQueue } from "./queues.server";

export interface QueueCounts {
  waiting: number;
  active: number;
  delayed: number;
  failed: number;
  completed: number;
}

export interface QueueHealth {
  redis: boolean;
  queues: Record<"sync" | "retry" | "deadLetter", QueueCounts>;
  healthy: boolean;
}

function toCounts(c: { [index: string]: number }): QueueCounts {
  return {
    waiting: c.waiting ?? 0,
    active: c.active ?? 0,
    delayed: c.delayed ?? 0,
    failed: c.failed ?? 0,
    completed: c.completed ?? 0,
  };
}

export async function getQueueHealth(): Promise<QueueHealth> {
  const redisOk = await pingRedis();

  const [sync, retry, deadLetter] = await Promise.all([
    syncQueue.getJobCounts("waiting", "active", "delayed", "failed", "completed"),
    retryQueue.getJobCounts("waiting", "active", "delayed", "failed", "completed"),
    deadLetterQueue.getJobCounts("waiting", "active", "delayed", "failed", "completed"),
  ]);

  return {
    redis: redisOk,
    queues: {
      sync: toCounts(sync),
      retry: toCounts(retry),
      deadLetter: toCounts(deadLetter),
    },
    healthy: redisOk,
  };
}
