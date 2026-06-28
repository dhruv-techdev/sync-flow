/// <reference types="vite/client" />
/// <reference types="@react-router/node" />

declare namespace NodeJS {
  interface ProcessEnv {
    // All optional: connection.server.ts and queue config.server.ts supply
    // defaults. Marking them required would misrepresent runtime behavior.
    REDIS_URL?: string;
    QUEUE_PREFIX?: string;
    QUEUE_CONCURRENCY?: string;
    QUEUE_MAX_ATTEMPTS?: string;
    QUEUE_BACKOFF_MS?: string;
    HEALTH_CHECK_TOKEN?: string;
  }
}
