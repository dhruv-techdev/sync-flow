import { Queue, QueueEvents } from "bullmq";
import { redis } from "~/lib/redis/connection.server";
import { queueLogger } from "~/lib/logger/logger.server";
import {
  QueueName,
  type DeadLetterPayload,
  type SyncJobPayload,
} from "./queues.types";
import { queueConfig } from "./config.server";

const { prefix, maxAttempts, backoffMs } = queueConfig;

const baseOpts = { connection: redis, prefix };

// --- ST-03: primary sync queue -----------------------------------------------
export const syncQueue = new Queue<SyncJobPayload>(QueueName.SYNC, {
  ...baseOpts,
  defaultJobOptions: {
    attempts: maxAttempts,
    backoff: { type: "exponential", delay: backoffMs }, // AC-004
    removeOnComplete: { age: 24 * 3600, count: 1000 },
    removeOnFail: false, // keep failures for inspection
  },
});

// --- ST-04: retry queue (delayed re-tries triggered manually) ----------------
export const retryQueue = new Queue<SyncJobPayload>(QueueName.RETRY, {
  ...baseOpts,
  defaultJobOptions: {
    attempts: 1,
    removeOnComplete: { age: 3600, count: 500 },
    removeOnFail: false,
  },
});

// --- ST-05: dead-letter queue (terminal failures, never auto-retried) --------
export const deadLetterQueue = new Queue<DeadLetterPayload>(
  QueueName.DEAD_LETTER,
  {
    ...baseOpts,
    defaultJobOptions: {
      attempts: 1,
      removeOnComplete: false,
      removeOnFail: false,
    },
  },
);

// --- Queue events: surface failures across processes (AC-006) ----------------
function attachEvents(name: string) {
  const events = new QueueEvents(name, { connection: redis.duplicate(), prefix });
  events.on("failed", ({ jobId, failedReason }) =>
    queueLogger.error({ queue: name, jobId, failedReason }, "job failed"),
  );
  events.on("completed", ({ jobId }) =>
    queueLogger.debug({ queue: name, jobId }, "job completed"),
  );
  events.on("stalled", ({ jobId }) =>
    queueLogger.warn({ queue: name, jobId }, "job stalled"),
  );
  return events;
}

export const queueEvents = {
  sync: attachEvents(QueueName.SYNC),
  retry: attachEvents(QueueName.RETRY),
  deadLetter: attachEvents(QueueName.DEAD_LETTER),
};

export async function closeQueues(): Promise<void> {
  await Promise.allSettled([
    queueEvents.sync.close(),
    queueEvents.retry.close(),
    queueEvents.deadLetter.close(),
    syncQueue.close(),
    retryQueue.close(),
    deadLetterQueue.close(),
  ]);
}
