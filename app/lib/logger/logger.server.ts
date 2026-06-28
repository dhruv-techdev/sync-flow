import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL ?? (process.env.NODE_ENV === "production" ? "info" : "debug"),
  base: { service: "syncflow" },
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: {
    paths: ["*.accessToken", "*.access_token", "*.password", "*.secret"],
    censor: "[REDACTED]",
  },
});

export const queueLogger = logger.child({ component: "queue" });
export const workerLogger = logger.child({ component: "worker" });
