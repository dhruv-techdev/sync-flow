// SyncFlow — shared status/enum constants
// Keep in sync with prisma/schema.prisma string fields.

export const SyncJobStatus = {
  QUEUED: "queued",
  PROCESSING: "processing",
  COMPLETED: "completed",
  FAILED: "failed",
  DEAD_LETTER: "dead_letter",
} as const;
export type SyncJobStatus = (typeof SyncJobStatus)[keyof typeof SyncJobStatus];

export const SyncMappingStatus = {
  PENDING: "pending",
  SYNCED: "synced",
  ERROR: "error",
} as const;
export type SyncMappingStatus =
  (typeof SyncMappingStatus)[keyof typeof SyncMappingStatus];

export const WebhookEventStatus = {
  RECEIVED: "received",
  PROCESSED: "processed",
  FAILED: "failed",
} as const;
export type WebhookEventStatus =
  (typeof WebhookEventStatus)[keyof typeof WebhookEventStatus];

export const RetryStatus = {
  PENDING: "pending",
  RETRIED: "retried",
  DEAD_LETTER: "dead_letter",
} as const;
export type RetryStatus = (typeof RetryStatus)[keyof typeof RetryStatus];

export const ConnectedStoreStatus = {
  ACTIVE: "active",
  PAUSED: "paused",
  DISCONNECTED: "disconnected",
} as const;
export type ConnectedStoreStatus =
  (typeof ConnectedStoreStatus)[keyof typeof ConnectedStoreStatus];

export const BillingStatus = {
  ACTIVE: "active",
  TRIALING: "trialing",
  PAST_DUE: "past_due",
  CANCELED: "canceled",
} as const;
export type BillingStatus = (typeof BillingStatus)[keyof typeof BillingStatus];

export const BillingPlan = {
  FREE: "free",
  STARTER: "starter",
  GROWTH: "growth",
  ENTERPRISE: "enterprise",
} as const;
export type BillingPlan = (typeof BillingPlan)[keyof typeof BillingPlan];

export const LogLevel = {
  INFO: "info",
  WARN: "warn",
  ERROR: "error",
} as const;
export type LogLevel = (typeof LogLevel)[keyof typeof LogLevel];

export const ActorType = {
  USER: "user",
  SYSTEM: "system",
  WEBHOOK: "webhook",
} as const;
export type ActorType = (typeof ActorType)[keyof typeof ActorType];
