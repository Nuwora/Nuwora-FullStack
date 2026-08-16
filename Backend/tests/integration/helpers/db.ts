import { execSync } from 'child_process';
import path from 'path';
import { PrismaClient } from '@prisma/client';
import { seedAchievements, seedExercises } from '../../../prisma/seedCatalog';

let migrated = false;

/** Applies migrations to the dedicated test schema once per test process. */
export function ensureTestDatabaseMigrated(): void {
  if (migrated) return;
  execSync('npx prisma migrate deploy', {
    cwd: path.resolve(__dirname, '../../..'),
    env: process.env,
    stdio: 'pipe',
  });
  migrated = true;
}

export const testPrisma = new PrismaClient();

export async function seedCatalog(): Promise<void> {
  await seedExercises(testPrisma);
  await seedAchievements(testPrisma);
}

/** Clears all user-generated data between tests while keeping the exercise/achievement catalog. */
export async function resetUserData(): Promise<void> {
  await testPrisma.processedMutation.deleteMany();
  await testPrisma.userAchievement.deleteMany();
  await testPrisma.chatMessage.deleteMany();
  await testPrisma.dailyUserExercise.deleteMany();
  await testPrisma.moodEntry.deleteMany();
  await testPrisma.mindFitnessScore.deleteMany();
  await testPrisma.onboardingAssessment.deleteMany();
  await testPrisma.deviceIdentity.deleteMany();
  await testPrisma.user.deleteMany();
}
