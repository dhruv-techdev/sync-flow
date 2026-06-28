// Shared queue identifiers and payload shapes.

export const QueueName = {
  SYNC: "sync",
  RETRY: "retry",
  DEAD_LETTER: "dead-letter",
} as const;
export type QueueName = (typeof QueueName)[keyof typeof QueueName];

export const JobName = {
  INVENTORY_SYNC: "inventory.sync",
  PRODUCT_SYNC: "product.sync",
} as const;
export type JobName = (typeof JobName)[keyof typeof JobName];

export interface SyncJobPayload {
  syncJobId: string;        // FK to SyncJob.id (Prisma)
  storeId: string;
  type: JobName;            // mirrors SyncJob.type; also the BullMQ job name
  data: Record<string, unknown>;
}

export interface DeadLetterPayload extends SyncJobPayload {
  failedReason: string;
  attemptsMade: number;
  originalJobId?: string;
  failedAt: string;         // ISO timestamp
}
