import { TxClient } from '../lib/idempotency';

export interface AchievementStats {
  completedExerciseCount: number;
  streakCount: number;
  moodEntryCount: number;
  level: number;
}

/**
 * Maps each seeded achievement's `criterionKey` to the rule that unlocks it.
 * Unknown/custom achievements (no matching key here) are simply never
 * auto-unlocked, which keeps this safe to extend.
 */
const ACHIEVEMENT_CRITERIA: Record<string, (stats: AchievementStats) => boolean> = {
  first_exercise: (stats) => stats.completedExerciseCount >= 1,
  streak_3: (stats) => stats.streakCount >= 3,
  mood_5: (stats) => stats.moodEntryCount >= 5,
  level_2: (stats) => stats.level >= 2,
};

export async function unlockEligibleAchievements(
  tx: TxClient,
  userId: string,
  stats: AchievementStats,
): Promise<void> {
  const criterionKeys = Object.keys(ACHIEVEMENT_CRITERIA);
  const candidates = await tx.achievement.findMany({
    where: { criterionKey: { in: criterionKeys } },
  });

  const eligibleAchievementIds = candidates
    .filter((achievement) => {
      const isMet = ACHIEVEMENT_CRITERIA[achievement.criterionKey];
      return isMet ? isMet(stats) : false;
    })
    .map((achievement) => achievement.id);

  if (eligibleAchievementIds.length === 0) {
    return;
  }

  await tx.userAchievement.createMany({
    data: eligibleAchievementIds.map((achievementId) => ({ userId, achievementId })),
    skipDuplicates: true,
  });
}
