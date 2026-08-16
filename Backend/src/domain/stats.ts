import { TxClient } from '../lib/idempotency';
import { levelForXP } from './xp';
import { AchievementStats } from './achievements';

export async function loadAchievementStats(
  tx: TxClient,
  userId: string,
): Promise<AchievementStats> {
  const user = await tx.user.findUniqueOrThrow({
    where: { id: userId },
    select: { xp: true, streakCount: true },
  });
  const [completedExerciseCount, moodEntryCount] = await Promise.all([
    tx.dailyUserExercise.count({ where: { userId, status: 'completed' } }),
    tx.moodEntry.count({ where: { userId } }),
  ]);

  return {
    completedExerciseCount,
    moodEntryCount,
    streakCount: user.streakCount,
    level: levelForXP(user.xp),
  };
}
