-- AlterTable
ALTER TABLE "Ets" ADD COLUMN     "subjectId" INTEGER;

-- CreateTable
CREATE TABLE "Subject" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "plan" TEXT NOT NULL,
    "semestre" INTEGER NOT NULL,
    "careerId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Subject_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Subject_careerId_idx" ON "Subject"("careerId");

-- CreateIndex
CREATE INDEX "Subject_plan_idx" ON "Subject"("plan");

-- CreateIndex
CREATE INDEX "Subject_semestre_idx" ON "Subject"("semestre");

-- CreateIndex
CREATE UNIQUE INDEX "Subject_careerId_plan_semestre_name_key" ON "Subject"("careerId", "plan", "semestre", "name");

-- CreateIndex
CREATE INDEX "Ets_subjectId_idx" ON "Ets"("subjectId");

-- AddForeignKey
ALTER TABLE "Subject" ADD CONSTRAINT "Subject_careerId_fkey" FOREIGN KEY ("careerId") REFERENCES "Career"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ets" ADD CONSTRAINT "Ets_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES "Subject"("id") ON DELETE SET NULL ON UPDATE CASCADE;
