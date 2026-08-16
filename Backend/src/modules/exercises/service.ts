import { PrismaClient } from '@prisma/client';
import { withIdempotency } from '../../lib/idempotency';
import { unlockEligibleAchievements } from '../../domain/achievements';
import { loadAchievementStats } from '../../domain/stats';
import { nextStreak } from '../../domain/streak';
import { ensureTodayPlanItem } from '../plans/service';
import { AppError } from '../../lib/errors';
import { CompleteExerciseInput, SkipExerciseInput } from './schema';

export async function completeExercise(
  prisma: PrismaClient,
  userId: string,
  exerciseId: string,
  input: CompleteExerciseInput,
): Promise<void> {
  await withIdempotency(
    prisma,
    { userId, clientMutationID: input.clientMutationID, mutationType: 'exercise_complete' },
    async (tx) => {
      const exercise = await tx.exercise.findUnique({ where: { id: exerciseId } });
      if (!exercise || !exercise.isActive) {
        throw AppError.notFound('Exercise not found.');
      }

      const daily = await ensureTodayPlanItem(tx, userId, exerciseId);
      const wasAlreadyCompleted = daily.status === 'completed';

      await tx.dailyUserExercise.update({
        where: { id: daily.id },
        data: {
          status: 'completed',
          performance: input.performance,
          completedAt: input.completedAt,
        },
      });

      if (!wasAlreadyCompleted) {
        const user = await tx.user.findUniqueOrThrow({
          where: { id: userId },
          select: { xp: true, streakCount: true, lastExerciseCompletedOn: true },
        });
        const streak = nextStreak(
          user.streakCount,
          user.lastExerciseCompletedOn,
          input.completedAt,
        );
        await tx.user.update({
          where: { id: userId },
          data: {
            xp: user.xp + exercise.xpReward,
            streakCount: streak.streakCount,
            lastExerciseCompletedOn: streak.lastExerciseCompletedOn,
          },
        });
      }

      const stats = await loadAchievementStats(tx, userId);
      await unlockEligibleAchievements(tx, userId, stats);
      return null;
    },
  );
}

export async function skipExercise(
  prisma: PrismaClient,
  userId: string,
  exerciseId: string,
  input: SkipExerciseInput,
): Promise<void> {
  await withIdempotency(
    prisma,
    { userId, clientMutationID: input.clientMutationID, mutationType: 'exercise_skip' },
    async (tx) => {
      const exercise = await tx.exercise.findUnique({ where: { id: exerciseId } });
      if (!exercise || !exercise.isActive) {
        throw AppError.notFound('Exercise not found.');
      }

      const daily = await ensureTodayPlanItem(tx, userId, exerciseId);
      if (daily.status === 'pending') {
        await tx.dailyUserExercise.update({
          where: { id: daily.id },
          data: { status: 'skipped', skippedAt: input.skippedAt },
        });
      }
      return null;
    },
  );
}
