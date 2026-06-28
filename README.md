<div align="center">

# 🔄 SyncFlow

### Shopify Multi-Store Inventory Synchronization SaaS

*Sync inventory across every store, location, and warehouse — in real time, without overselling.*

<br/>

[![Version](https://img.shields.io/badge/version-1.0-6E56CF?style=for-the-badge)](#)
[![Status](https://img.shields.io/badge/status-Final%20Draft-F5A623?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/license-Proprietary-555?style=for-the-badge)](#)

[![React Router](https://img.shields.io/badge/React%20Router-7-CA4245?style=flat-square&logo=reactrouter&logoColor=white)](https://reactrouter.com/)
[![Shopify](https://img.shields.io/badge/Shopify-Embedded%20App-95BF47?style=flat-square&logo=shopify&logoColor=white)](https://shopify.dev/)
[![Prisma](https://img.shields.io/badge/Prisma-PostgreSQL-2D3748?style=flat-square&logo=prisma&logoColor=white)](https://www.prisma.io/)
[![BullMQ](https://img.shields.io/badge/BullMQ-Redis-DC382D?style=flat-square&logo=redis&logoColor=white)](https://docs.bullmq.io/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Node](https://img.shields.io/badge/Node-20%20%7C%2022-339933?style=flat-square&logo=nodedotjs&logoColor=white)](https://nodejs.org/)

<br/>

[Getting Started](#-getting-started) ·
[Features](#-features) ·
[Architecture](#-architecture--tech-stack) ·
[Roadmap](#-delivery-roadmap)

</div>

---

> **SyncFlow** is a Shopify embedded SaaS application that synchronizes inventory across multiple Shopify stores, retail locations, warehouses, and future marketplace integrations. It is designed to prevent overselling, inventory mismatches, delayed stock updates, and the manual operational overhead faced by merchants running complex commerce operations.

<table>
<tr>
<td><b>📦 Application</b></td><td>SyncFlow</td>
<td><b>🧩 Type</b></td><td>Shopify embedded app (SaaS)</td>
</tr>
<tr>
<td><b>👤 Author</b></td><td>Dhruv Patel</td>
<td><b>🏷️ Version</b></td><td>1.0</td>
</tr>
<tr>
<td><b>📅 Date</b></td><td>June 2026</td>
<td><b>📍 Status</b></td><td>Final Draft</td>
</tr>
</table>

---

## 🎯 Product Vision

The long-term vision of SyncFlow is to become a centralized inventory synchronization and intelligence platform for Shopify merchants. The product starts with reliable multi-store synchronization and expands toward marketplace integrations, ERP connections, warehouse systems, analytics, and AI-powered recommendations.

- Position SyncFlow as a reliable, observable, and scalable alternative to slow or unclear inventory sync tools.
- Support Shopify merchants managing multiple storefronts, locations, warehouses, or agencies.
- Build a SaaS platform with subscription billing, usage controls, monitoring, and plan-based feature gating.
- Create a technical foundation suitable for future Amazon, Walmart, TikTok Shop, ERP, and warehouse integrations.

## ❗ The Problem

- Merchants oversell products when stock changes aren't propagated fast enough.
- Inventory levels become inconsistent across multiple stores and locations.
- Manual inventory management creates operational delays and human error.
- Existing tools often lack observability, retry handling, webhook transparency, or scalable architecture.
- Shopify Plus and DTC brands need reliable synchronization across high-volume stores.

---

## ✨ Features

### ✅ In Scope

- Multi-store Shopify connection management.
- Store grouping and store-level sync permissions.
- SKU, variant, inventory item, and location-aware inventory mapping.
- Manual inventory synchronization from the merchant dashboard.
- Scheduled inventory synchronization as a fallback mechanism.
- Webhook-triggered synchronization for orders, inventory updates, product updates, refunds, and restocks.
- Redis-backed queue processing with retries and dead-letter queues.
- Shopify Admin GraphQL API integration for products, variants, inventory items, locations, and inventory levels.
- Sync logs, discrepancy reporting, latency metrics, and failure monitoring.
- Shopify subscription billing with Starter, Growth, and Scale tiers.
- Plan-based store limits and sync volume limits.
- Tenant isolation, audit logging, secure token handling, and webhook HMAC verification.
- AI insight foundation for imbalance detection, smart recommendations, and basic demand forecasting.
- Production readiness including CI/CD, monitoring, health checks, rollback checklist, and release notes.

### 🚫 Out of Scope (MVP)

- Direct Amazon, Walmart, TikTok Shop, or eBay marketplace integrations.
- Full ERP integration (NetSuite, SAP, Microsoft Dynamics).
- Advanced warehouse management system replacement features.
- Full AI demand forecasting model with guaranteed prediction accuracy.
- Multi-currency billing outside the Shopify billing flow.
- Custom enterprise SLA dashboard before v1.0.0.
- Native mobile application.

---

## 🏗️ Architecture & Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | [React Router 7](https://reactrouter.com/) (embedded Shopify app) |
| Shopify | [@shopify/shopify-app-react-router](https://shopify.dev/docs/api/shopify-app-react-router), App Bridge, Polaris |
| API integration | Shopify Admin GraphQL API |
| Database | PostgreSQL via [Prisma](https://www.prisma.io/) |
| Queue / Workers | [BullMQ](https://docs.bullmq.io/) + [Redis](https://redis.io/) (ioredis) |
| Logging | [pino](https://getpino.io/) |
| Runtime | Node.js `>=20.19 <22 || >=22.12` |

### 📁 Project Layout

```
sync-flow/
├── app/
│   ├── lib/
│   │   ├── db/          # Prisma client (db.server)
│   │   ├── logger/      # pino logger
│   │   ├── queue/       # BullMQ config, producer, queues, health
│   │   ├── redis/       # Redis connection
│   │   └── types/       # Shared sync types
│   ├── routes/          # React Router routes + webhooks + health API
│   ├── shopify.server.ts
│   └── root.tsx
├── workers/
│   └── sync.worker.ts   # Background sync worker (BullMQ consumer)
├── prisma/
│   └── schema.prisma    # PostgreSQL schema
└── extensions/          # Shopify app extensions
```

---

## 🚀 Getting Started

### Prerequisites

- [Shopify CLI](https://shopify.dev/docs/apps/tools/cli/getting-started)
- Node.js (see `engines` in `package.json`)
- A running PostgreSQL instance (`DATABASE_URL`, `DIRECT_URL`)
- A running Redis instance (for the sync queue and workers)
- [pnpm](https://pnpm.io/) (this repo uses a `pnpm-lock.yaml`)

### Setup

```shell
pnpm install
pnpm run setup        # prisma generate && prisma migrate deploy
```

### Local Development

Run the embedded app and the sync worker in separate terminals:

```shell
pnpm run dev          # Shopify app dev (embedded app)
pnpm run worker:dev   # BullMQ sync worker (watch mode)
```

Press `P` to open the app URL. After installing the app, you can start development.

### Useful Scripts

| Script | Description |
| --- | --- |
| `pnpm run dev` | Run the embedded app via Shopify CLI |
| `pnpm run worker` | Run the BullMQ sync worker |
| `pnpm run worker:dev` | Run the sync worker in watch mode |
| `pnpm run build` | Build the app for production |
| `pnpm run start` | Serve the production build |
| `pnpm run setup` | Generate Prisma client and apply migrations |
| `pnpm run typecheck` | Type generation + `tsc --noEmit` |
| `pnpm run lint` | Run ESLint |
| `pnpm run queue:health` | Check queue health (`/api/health/queue`) |

---

## 🗺️ Delivery Roadmap

SyncFlow is delivered in sprint-based releases.

| Release | Sprint(s) | Scope |
| --- | --- | --- |
| **v0.1.0** Foundation | 1 | Prisma schema, Redis queues, tenant-aware services, logging foundation |
| **v0.2.0** Store Connectivity | 2 | Connect/manage multiple stores, dashboard, groups, permissions |
| **v0.3.0** Inventory Mapping | 3 | SKU/variant/product/location mapping and validation |
| **v0.4.0** Sync Engine | 4–6 | Manual, scheduled & webhook-triggered sync, retries, DLQ, rate limits |
| **v0.5.0** Analytics | 7 | Activity dashboard, discrepancy reports, latency & failure tracking |
| **v0.6.0** Billing | 8 | Shopify billing, plan limits, usage controls |
| **v0.7.0** AI Insights | 9 | Imbalance detection, recommendations, forecasting foundation |
| **v1.0.0** Production | 10 | CI/CD, observability, security review, production readiness |

---

## 👥 User Roles

| Role | Responsibilities | Permissions |
| --- | --- | --- |
| Merchant Admin | App setup, store connections, billing, sync rules | Full tenant-level |
| Operations Manager | Monitors inventory, sync status, discrepancies, failures | View & manage sync operations |
| Warehouse Manager | Reviews warehouse-aware inventory and location mappings | View & update assigned mappings |
| Support Analyst | Investigates failed syncs, webhook events, DLQ jobs | Read-only support / troubleshooting |
| Platform Super Admin | Internal platform settings, incidents, operational health | Internal admin |

---

## 🛡️ Engineering Principles & Constraints

- **Respect Shopify API rate limits** — use GraphQL cost tracking, throttling, queue delays, and retries.
- **Idempotency required** — webhook delivery is not guaranteed exactly-once; use idempotency keys and unique constraints.
- **No inventory race conditions** — use sync locks, conflict rules, and serialized processing per mapping.
- **Tenant isolation enforced** — all merchant-facing data flows through tenant-scoped services and authorization guards.
- **Non-blocking sync** — sync operations run asynchronously and must never block embedded app page requests.
- **Secrets never committed** — production secrets stay out of version control.
- **Reliability over AI** — the MVP prioritizes a dependable sync core before advanced AI features.

## 🎯 Success Criteria

| Category | Criteria |
| --- | --- |
| Functional | Connect stores, map inventory, and run sync jobs |
| Reliability | Failed jobs retry; exhausted jobs move to the dead-letter queue |
| Security | Webhook HMAC verified; tenant isolation enforced |
| Performance | Sync runs asynchronously and respects Shopify rate limits |
| Observability | Sync activity, failures, latency, and discrepancies are visible |
| SaaS | Billing plans and usage limits are enforced |
| Deployment | Staging and production workflows are documented and testable |

---

## 📦 Deployment

The app builds to a standard Node server (`pnpm run build` → `pnpm run start`) and ships with a `Dockerfile`. See Shopify's [deployment documentation](https://shopify.dev/docs/apps/launch/deployment) for hosting options (Google Cloud Run, Fly.io, Render, or manual). Remember to set `NODE_ENV=production` and provide `DATABASE_URL`, `DIRECT_URL`, and Redis connection variables.

The sync worker (`workers/sync.worker.ts`) must be run as a separate long-lived process alongside the web server.

## 📚 Resources

- [React Router docs](https://reactrouter.com/home)
- [Shopify App React Router docs](https://shopify.dev/docs/api/shopify-app-react-router)
- [Shopify Admin GraphQL API](https://shopify.dev/docs/api/admin-graphql)
- [Shopify CLI](https://shopify.dev/docs/apps/tools/cli)
- [BullMQ docs](https://docs.bullmq.io/)
- [Prisma docs](https://www.prisma.io/docs)

---

<div align="center">

**SyncFlow** — built by Dhruv Patel · Reliable inventory sync for Shopify merchants.

<sub>⭐ Reliability over hype · 🔒 Tenant-isolated by design · ⚡ Async, observable, scalable</sub>

</div>
