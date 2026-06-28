import "dotenv/config";
import { Worker, type Job } from "bullmq";
import { redis } from "../app/lib/redis/connection.server";
import { workerLogger } from "../app/lib/logger/logger.server";
import { pushToDeadLetter } from "../app/lib/queue/producer.server";
import { QueueName, type SyncJobPayload } from "../app/lib/queue/queues.types";
import { queueConfig } from "../app/lib/queue/config.server";

const { prefix, concurrency } = queueConfig;

/**
 * Job processor.
 * Real Shopify GraphQL sync lands here in US-004+. For now this is a stub
 * that proves the queue plumbing end-to-end.
 */
async function processSyncJob(job: Job<SyncJobPayload>) {
  workerLogger.info(
    {
      queue: job.queueName,
      jobId: job.id,
      attempt: job.attemptsMade + 1,
      storeId: job.data.storeId,
      type: job.data.type,
    },
    "processing sync job",
  );

  // TODO US-004: dispatch by job.data.type → Shopify Admin GraphQL call.
  // Throw to trigger BullMQ's exponential backoff (AC-004).
  return { ok: true, processedAt: new Date().toISOString() };
}

/** Move a job whose attempts are exhausted into the DLQ (AC-005). */
async function handleFailure(job: Job<SyncJobPayload> | undefined, err: Error) {
  if (!job) {
    workerLogger.error({ err }, "job failed with no job reference");
    return;
  }
  workerLogger.error(
    {
      queue: job.queueName,
      jobId: job.id,
      attemptsMade: job.attemptsMade,
      err: err.message,
    },
    "job failed",
  );

  const maxAttempts = job.opts.attempts ?? 1;
  if (job.attemptsMade >= maxAttempts) {
    await pushToDeadLetter({
      ...job.data,
      failedReason: err.message,
      attemptsMade: job.attemptsMade,
      originalJobId: job.id,
      failedAt: new Date().toISOString(),
    });
  }
}

/** Start a worker for a queue using the shared processor + failure handling. */
function startWorker(queueName: QueueName): Worker<SyncJobPayload> {
  const worker = new Worker<SyncJobPayload>(queueName, processSyncJob, {
    connection: redis,
    prefix,
    concurrency,
  });

  worker.on("completed", (job) =>
    workerLogger.info({ queue: queueName, jobId: job.id }, "job completed"),
  );
  worker.on("failed", (job, err) => handleFailure(job, err));
  worker.on("error", (err) =>
    workerLogger.error({ queue: queueName, err }, "worker error"),
  );

  return worker;
}

// The retry queue holds manually re-queued jobs (ST-04); it needs its own
// consumer or those jobs would sit unprocessed forever.
const workers = [startWorker(QueueName.SYNC), startWorker(QueueName.RETRY)];

async function shutdown(signal: string) {
  workerLogger.warn({ signal }, "shutting down workers");
  await Promise.allSettled(workers.map((w) => w.close()));
  await redis.quit();
  process.exit(0);
}
process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));

workerLogger.info(
  { concurrency, prefix, queues: [QueueName.SYNC, QueueName.RETRY] },
  "sync worker started",
);
