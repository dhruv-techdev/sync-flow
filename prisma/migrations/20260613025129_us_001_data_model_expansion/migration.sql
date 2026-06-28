-- CreateTable
CREATE TABLE "Store" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "shopDomain" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT,
    "plan" TEXT NOT NULL DEFAULT 'free',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "installedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "uninstalledAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Store_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ConnectedStore" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "shopDomain" TEXT,
    "accessToken" TEXT NOT NULL,
    "scopes" TEXT,
    "status" TEXT NOT NULL DEFAULT 'active',
    "metadata" JSONB,
    "connectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ConnectedStore_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProductReference" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "shopifyProductId" TEXT NOT NULL,
    "title" TEXT,
    "handle" TEXT,
    "status" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProductReference_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VariantReference" (
    "id" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "shopifyVariantId" TEXT NOT NULL,
    "sku" TEXT,
    "title" TEXT,
    "price" DECIMAL(65,30),
    "inventoryItemId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "VariantReference_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InventoryMapping" (
    "id" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "connectedStoreId" TEXT NOT NULL,
    "externalVariantId" TEXT,
    "externalSku" TEXT,
    "syncStatus" TEXT NOT NULL DEFAULT 'pending',
    "lastSyncedAt" TIMESTAMP(3),
    "quantity" INTEGER NOT NULL DEFAULT 0,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "InventoryMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SyncJob" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'queued',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "payload" JSONB NOT NULL,
    "result" JSONB,
    "error" TEXT,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "maxAttempts" INTEGER NOT NULL DEFAULT 5,
    "scheduledAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SyncJob_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SyncLog" (
    "id" TEXT NOT NULL,
    "syncJobId" TEXT NOT NULL,
    "level" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "context" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SyncLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WebhookEvent" (
    "id" TEXT NOT NULL,
    "storeId" TEXT,
    "eventId" TEXT NOT NULL,
    "topic" TEXT NOT NULL,
    "shopDomain" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'received',
    "processedAt" TIMESTAMP(3),
    "error" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RetryQueue" (
    "id" TEXT NOT NULL,
    "syncJobId" TEXT NOT NULL,
    "attempt" INTEGER NOT NULL,
    "nextAttemptAt" TIMESTAMP(3) NOT NULL,
    "reason" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RetryQueue_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BillingSubscription" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "plan" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active',
    "shopifyChargeId" TEXT,
    "trialEndsAt" TIMESTAMP(3),
    "currentPeriodEnd" TIMESTAMP(3),
    "canceledAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BillingSubscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "storeId" TEXT,
    "actorId" TEXT,
    "actorType" TEXT,
    "action" TEXT NOT NULL,
    "resource" TEXT,
    "context" JSONB,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InventorySnapshot" (
    "id" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "variantId" TEXT NOT NULL,
    "sku" TEXT,
    "quantity" INTEGER NOT NULL,
    "source" TEXT,
    "takenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "InventorySnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Store_tenantId_key" ON "Store"("tenantId");

-- CreateIndex
CREATE UNIQUE INDEX "Store_shopDomain_key" ON "Store"("shopDomain");

-- CreateIndex
CREATE INDEX "Store_tenantId_idx" ON "Store"("tenantId");

-- CreateIndex
CREATE INDEX "Store_shopDomain_idx" ON "Store"("shopDomain");

-- CreateIndex
CREATE INDEX "Store_createdAt_idx" ON "Store"("createdAt");

-- CreateIndex
CREATE INDEX "ConnectedStore_storeId_idx" ON "ConnectedStore"("storeId");

-- CreateIndex
CREATE INDEX "ConnectedStore_provider_idx" ON "ConnectedStore"("provider");

-- CreateIndex
CREATE INDEX "ConnectedStore_status_idx" ON "ConnectedStore"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ConnectedStore_storeId_provider_externalId_key" ON "ConnectedStore"("storeId", "provider", "externalId");

-- CreateIndex
CREATE INDEX "ProductReference_storeId_idx" ON "ProductReference"("storeId");

-- CreateIndex
CREATE INDEX "ProductReference_shopifyProductId_idx" ON "ProductReference"("shopifyProductId");

-- CreateIndex
CREATE UNIQUE INDEX "ProductReference_storeId_shopifyProductId_key" ON "ProductReference"("storeId", "shopifyProductId");

-- CreateIndex
CREATE INDEX "VariantReference_sku_idx" ON "VariantReference"("sku");

-- CreateIndex
CREATE INDEX "VariantReference_shopifyVariantId_idx" ON "VariantReference"("shopifyVariantId");

-- CreateIndex
CREATE UNIQUE INDEX "VariantReference_productId_shopifyVariantId_key" ON "VariantReference"("productId", "shopifyVariantId");

-- CreateIndex
CREATE INDEX "InventoryMapping_variantId_idx" ON "InventoryMapping"("variantId");

-- CreateIndex
CREATE INDEX "InventoryMapping_connectedStoreId_idx" ON "InventoryMapping"("connectedStoreId");

-- CreateIndex
CREATE INDEX "InventoryMapping_externalSku_idx" ON "InventoryMapping"("externalSku");

-- CreateIndex
CREATE INDEX "InventoryMapping_syncStatus_idx" ON "InventoryMapping"("syncStatus");

-- CreateIndex
CREATE UNIQUE INDEX "InventoryMapping_variantId_connectedStoreId_key" ON "InventoryMapping"("variantId", "connectedStoreId");

-- CreateIndex
CREATE INDEX "SyncJob_storeId_idx" ON "SyncJob"("storeId");

-- CreateIndex
CREATE INDEX "SyncJob_status_idx" ON "SyncJob"("status");

-- CreateIndex
CREATE INDEX "SyncJob_type_idx" ON "SyncJob"("type");

-- CreateIndex
CREATE INDEX "SyncJob_scheduledAt_idx" ON "SyncJob"("scheduledAt");

-- CreateIndex
CREATE INDEX "SyncJob_createdAt_idx" ON "SyncJob"("createdAt");

-- CreateIndex
CREATE INDEX "SyncLog_syncJobId_idx" ON "SyncLog"("syncJobId");

-- CreateIndex
CREATE INDEX "SyncLog_level_idx" ON "SyncLog"("level");

-- CreateIndex
CREATE INDEX "SyncLog_createdAt_idx" ON "SyncLog"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "WebhookEvent_eventId_key" ON "WebhookEvent"("eventId");

-- CreateIndex
CREATE INDEX "WebhookEvent_storeId_idx" ON "WebhookEvent"("storeId");

-- CreateIndex
CREATE INDEX "WebhookEvent_topic_idx" ON "WebhookEvent"("topic");

-- CreateIndex
CREATE INDEX "WebhookEvent_shopDomain_idx" ON "WebhookEvent"("shopDomain");

-- CreateIndex
CREATE INDEX "WebhookEvent_status_idx" ON "WebhookEvent"("status");

-- CreateIndex
CREATE INDEX "WebhookEvent_createdAt_idx" ON "WebhookEvent"("createdAt");

-- CreateIndex
CREATE INDEX "RetryQueue_syncJobId_idx" ON "RetryQueue"("syncJobId");

-- CreateIndex
CREATE INDEX "RetryQueue_nextAttemptAt_idx" ON "RetryQueue"("nextAttemptAt");

-- CreateIndex
CREATE INDEX "RetryQueue_status_idx" ON "RetryQueue"("status");

-- CreateIndex
CREATE UNIQUE INDEX "BillingSubscription_storeId_key" ON "BillingSubscription"("storeId");

-- CreateIndex
CREATE INDEX "BillingSubscription_status_idx" ON "BillingSubscription"("status");

-- CreateIndex
CREATE INDEX "BillingSubscription_plan_idx" ON "BillingSubscription"("plan");

-- CreateIndex
CREATE INDEX "AuditLog_storeId_idx" ON "AuditLog"("storeId");

-- CreateIndex
CREATE INDEX "AuditLog_action_idx" ON "AuditLog"("action");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE INDEX "InventorySnapshot_storeId_idx" ON "InventorySnapshot"("storeId");

-- CreateIndex
CREATE INDEX "InventorySnapshot_variantId_idx" ON "InventorySnapshot"("variantId");

-- CreateIndex
CREATE INDEX "InventorySnapshot_sku_idx" ON "InventorySnapshot"("sku");

-- CreateIndex
CREATE INDEX "InventorySnapshot_takenAt_idx" ON "InventorySnapshot"("takenAt");

-- AddForeignKey
ALTER TABLE "ConnectedStore" ADD CONSTRAINT "ConnectedStore_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProductReference" ADD CONSTRAINT "ProductReference_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VariantReference" ADD CONSTRAINT "VariantReference_productId_fkey" FOREIGN KEY ("productId") REFERENCES "ProductReference"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InventoryMapping" ADD CONSTRAINT "InventoryMapping_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "VariantReference"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InventoryMapping" ADD CONSTRAINT "InventoryMapping_connectedStoreId_fkey" FOREIGN KEY ("connectedStoreId") REFERENCES "ConnectedStore"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SyncJob" ADD CONSTRAINT "SyncJob_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SyncLog" ADD CONSTRAINT "SyncLog_syncJobId_fkey" FOREIGN KEY ("syncJobId") REFERENCES "SyncJob"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WebhookEvent" ADD CONSTRAINT "WebhookEvent_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RetryQueue" ADD CONSTRAINT "RetryQueue_syncJobId_fkey" FOREIGN KEY ("syncJobId") REFERENCES "SyncJob"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BillingSubscription" ADD CONSTRAINT "BillingSubscription_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InventorySnapshot" ADD CONSTRAINT "InventorySnapshot_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InventorySnapshot" ADD CONSTRAINT "InventorySnapshot_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "VariantReference"("id") ON DELETE CASCADE ON UPDATE CASCADE;
