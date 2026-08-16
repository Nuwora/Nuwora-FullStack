-- DropIndex
DROP INDEX "chat_messages_userId_createdAt_idx";

-- AlterTable
ALTER TABLE "chat_messages" ADD COLUMN     "sequence" SERIAL NOT NULL;

-- CreateIndex
CREATE INDEX "chat_messages_userId_sequence_idx" ON "chat_messages"("userId", "sequence");
