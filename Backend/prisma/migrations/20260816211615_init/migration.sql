-- CreateEnum
CREATE TYPE "Goal" AS ENUM ('focus', 'stress_relief', 'memory', 'resilience');

-- CreateEnum
CREATE TYPE "Wearable" AS ENUM ('apple_watch', 'oura', 'fitbit', 'whoop');

-- CreateEnum
CREATE TYPE "ExerciseType" AS ENUM ('breathing', 'cognitive', 'mindfulness', 'focus', 'journaling');

-- CreateEnum
CREATE TYPE "CoachPersona" AS ENUM ('zen_monk', 'peak_performer', 'neuroscientist');

-- CreateEnum
CREATE TYPE "MessageSender" AS ENUM ('user', 'coach');

-- CreateEnum
CREATE TYPE "DailyExerciseStatus" AS ENUM ('pending', 'completed', 'skipped');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "age" INTEGER,
    "primaryGoals" "Goal"[] DEFAULT ARRAY[]::"Goal"[],
    "connectedWearables" "Wearable"[] DEFAULT ARRAY[]::"Wearable"[],
    "xp" INTEGER NOT NULL DEFAULT 0,
    "streakCount" INTEGER NOT NULL DEFAULT 0,
    "lastExerciseCompletedOn" DATE,
    "leaderboardAlias" TEXT NOT NULL,
    "onboardingCompletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_identities" (
    "id" TEXT NOT NULL,
    "deviceID" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "device_identities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "onboarding_assessments" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "answers" INTEGER[],
    "overallScore" INTEGER NOT NULL,
    "cognitiveScore" INTEGER NOT NULL,
    "biometricScore" INTEGER NOT NULL,
    "moodScore" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "onboarding_assessments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exercises" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subtitle" TEXT NOT NULL,
    "type" "ExerciseType" NOT NULL,
    "durationSeconds" INTEGER NOT NULL,
    "difficulty" INTEGER NOT NULL,
    "xpReward" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "exercises_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "daily_user_exercises" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "exerciseId" TEXT NOT NULL,
    "planDate" DATE NOT NULL,
    "status" "DailyExerciseStatus" NOT NULL DEFAULT 'pending',
    "performance" DOUBLE PRECISION,
    "completedAt" TIMESTAMP(3),
    "skippedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "daily_user_exercises_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mood_entries" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "mood" INTEGER NOT NULL,
    "occurredAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mood_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mind_fitness_scores" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "overallScore" INTEGER NOT NULL,
    "cognitiveScore" INTEGER NOT NULL,
    "biometricScore" INTEGER NOT NULL,
    "moodScore" INTEGER NOT NULL,
    "focusSubscore" INTEGER NOT NULL,
    "calmSubscore" INTEGER NOT NULL,
    "energySubscore" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mind_fitness_scores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_messages" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "sender" "MessageSender" NOT NULL,
    "persona" "CoachPersona",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "achievements" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "iconName" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "criterionKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "achievements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_achievements" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "achievementId" TEXT NOT NULL,
    "unlockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_achievements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "processed_mutations" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "clientMutationID" TEXT NOT NULL,
    "mutationType" TEXT NOT NULL,
    "responseBody" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "processed_mutations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "device_identities_deviceID_key" ON "device_identities"("deviceID");

-- CreateIndex
CREATE UNIQUE INDEX "device_identities_userId_key" ON "device_identities"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "onboarding_assessments_userId_key" ON "onboarding_assessments"("userId");

-- CreateIndex
CREATE INDEX "daily_user_exercises_userId_planDate_idx" ON "daily_user_exercises"("userId", "planDate");

-- CreateIndex
CREATE UNIQUE INDEX "daily_user_exercises_userId_exerciseId_planDate_key" ON "daily_user_exercises"("userId", "exerciseId", "planDate");

-- CreateIndex
CREATE INDEX "mood_entries_userId_occurredAt_idx" ON "mood_entries"("userId", "occurredAt");

-- CreateIndex
CREATE INDEX "mind_fitness_scores_userId_date_idx" ON "mind_fitness_scores"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "mind_fitness_scores_userId_date_key" ON "mind_fitness_scores"("userId", "date");

-- CreateIndex
CREATE INDEX "chat_messages_userId_createdAt_idx" ON "chat_messages"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "achievements_criterionKey_key" ON "achievements"("criterionKey");

-- CreateIndex
CREATE UNIQUE INDEX "user_achievements_userId_achievementId_key" ON "user_achievements"("userId", "achievementId");

-- CreateIndex
CREATE UNIQUE INDEX "processed_mutations_userId_clientMutationID_key" ON "processed_mutations"("userId", "clientMutationID");

-- AddForeignKey
ALTER TABLE "device_identities" ADD CONSTRAINT "device_identities_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "onboarding_assessments" ADD CONSTRAINT "onboarding_assessments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_user_exercises" ADD CONSTRAINT "daily_user_exercises_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_user_exercises" ADD CONSTRAINT "daily_user_exercises_exerciseId_fkey" FOREIGN KEY ("exerciseId") REFERENCES "exercises"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mood_entries" ADD CONSTRAINT "mood_entries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mind_fitness_scores" ADD CONSTRAINT "mind_fitness_scores_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_achievements" ADD CONSTRAINT "user_achievements_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_achievements" ADD CONSTRAINT "user_achievements_achievementId_fkey" FOREIGN KEY ("achievementId") REFERENCES "achievements"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "processed_mutations" ADD CONSTRAINT "processed_mutations_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
