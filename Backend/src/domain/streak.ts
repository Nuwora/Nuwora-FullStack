import { utcDaysBetween } from './dates';

export interface StreakUpdate {
  streakCount: number;
  lastExerciseCompletedOn: Date;
}

/**
 * Recomputes the streak after an exercise completion.
 * - First-ever completion starts the streak at 1.
 * - Completing again on the same UTC day the streak was last advanced is a no-op.
 * - Completing on the very next UTC day increments the streak.
 * - Completing after a gap of more than one UTC day resets the streak to 1.
 */
export function nextStreak(
  currentStreak: number,
  lastExerciseCompletedOn: Date | null,
  completedAt: Date,
): StreakUpdate {
  if (!lastExerciseCompletedOn) {
    return { streakCount: 1, lastExerciseCompletedOn: completedAt };
  }

  const dayDiff = utcDaysBetween(lastExerciseCompletedOn, completedAt);

  if (dayDiff === 0) {
    return { streakCount: currentStreak, lastExerciseCompletedOn };
  }
  if (dayDiff === 1) {
    return { streakCount: currentStreak + 1, lastExerciseCompletedOn: completedAt };
  }
  return { streakCount: 1, lastExerciseCompletedOn: completedAt };
}
