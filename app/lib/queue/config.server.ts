// Centralized, validated queue configuration.
// All QUEUE_* env vars are optional; these defaults are the source of truth.

function intEnv(name: string, fallback: number): number {
  const raw = process.env[name];
  if (raw === undefined || raw.trim() === "") return fallback;
  const parsed = Number(raw);
  if (!Number.isFinite(parsed) || parsed < 0) {
    throw new Error(
      `Invalid ${name}="${raw}": expected a non-negative number`,
    );
  }
  return parsed;
}

export const queueConfig = {
  prefix: process.env.QUEUE_PREFIX?.trim() || "syncflow",
  maxAttempts: intEnv("QUEUE_MAX_ATTEMPTS", 5),
  backoffMs: intEnv("QUEUE_BACKOFF_MS", 2000),
  concurrency: intEnv("QUEUE_CONCURRENCY", 5),
} as const;
