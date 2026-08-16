import { DailyExerciseStatus, Exercise } from '@prisma/client';

export interface ExerciseJSON {
  id: string;
  title: string;
  subtitle: string;
  type: string;
  durationSeconds: number;
  difficulty: number;
  xpReward: number;
  isCompleted: boolean;
}

export function serializeExercise(
  exercise: Exercise,
  status: DailyExerciseStatus | null,
): ExerciseJSON {
  return {
    id: exercise.id,
    title: exercise.title,
    subtitle: exercise.subtitle,
    type: exercise.type,
    durationSeconds: exercise.durationSeconds,
    difficulty: exercise.difficulty,
    xpReward: exercise.xpReward,
    isCompleted: status === 'completed',
  };
}
