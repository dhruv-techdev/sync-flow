import type { LoaderFunctionArgs } from "react-router";
import { getQueueHealth } from "~/lib/queue/health.server";
import { workerLogger } from "~/lib/logger/logger.server";

/**
 * Queue health probe.
 *
 * Optional access control: if HEALTH_CHECK_TOKEN is set, callers must present
 * `Authorization: Bearer <token>`. This keeps internal queue state off a public
 * Shopify app URL while still allowing unauthenticated probes locally.
 */
export async function loader({ request }: LoaderFunctionArgs) {
  const token = process.env.HEALTH_CHECK_TOKEN;
  if (token) {
    const auth = request.headers.get("authorization");
    if (auth !== `Bearer ${token}`) {
      return Response.json({ error: "unauthorized" }, { status: 401 });
    }
  }

  try {
    const health = await getQueueHealth();
    return Response.json(health, { status: health.healthy ? 200 : 503 });
  } catch (err) {
    // Never let an infra failure surface as a 500 — report unhealthy instead.
    workerLogger.error({ err }, "queue health check failed");
    return Response.json(
      { healthy: false, error: "health check failed" },
      { status: 503 },
    );
  }
}
