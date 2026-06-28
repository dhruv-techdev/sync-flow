import { JobsOptions } from "bullmq";
import {
  deadLetterQueue,
  retryQueue,
  syncQueue,
} from "./queues.server";
import {
  type DeadLetterPayload,
  type SyncJobPayload,
} from "./queues.types";
import { queueLogger } from "~/lib/logger/logger.server";

/**
 * Enqueue a sync job, routed by its declared type (inventory vs product).
 * jobId === SyncJob.id gives us idempotency: BullMQ rejects duplicates.
 */
export async function enqueueSyncJob(
  payload: SyncJobPayload,
  opts: JobsOptions = {},
) {
  const job = await syncQueue.add(payload.type, payload, {
    jobId: payload.syncJobId,
    ...opts,
  });
  queueLogger.info(
    { jobId: job.id, storeId: payload.storeId, type: payload.type },
    "sync job enqueued",
  );
  return job;
}

/** Schedule a delayed retry (used by manual "Retry" UI actions). */
export async function enqueueRetry(
  payload: SyncJobPayload,
  delayMs: number,
) {
  const job = await retryQueue.add(payload.type, payload, {
    delay: delayMs,
  });
  queueLogger.info(
    { jobId: job.id, storeId: payload.storeId, delayMs },
    "retry scheduled",
  );
  return job;
}

/** Push an exhausted job into the DLQ (AC-005). */
export async function pushToDeadLetter(payload: DeadLetterPayload) {
  const job = await deadLetterQueue.add(payload.type, payload);
  queueLogger.error(
    {
      jobId: job.id,
      storeId: payload.storeId,
      attemptsMade: payload.attemptsMade,
      failedReason: payload.failedReason,
    },
    "job moved to dead-letter",
  );
  return job;
}
