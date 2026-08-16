import { DailyUserExercise, Exercise, PrismaClient } from '@prisma/client';
import { utcDayStart } from '../../domain/dates';
import { TxClient } from '../../lib/idempotency';

type DB = PrismaClient | TxClient;

export const TODAY_PLAN_MAX_EXERCISES = 5;

export interface PlanItem {
  exercise: Exercise;
  daily: DailyUserExercise;
}

/** Ensures today's plan rows exist for the user and returns them joined with their exercise. */
export async function ensureTodayPlan(prisma: PrismaClient, userId: string): Promise<PlanItem[]> {
  const planDate = utcDayStart(new Date());

  const activeExercises = await prisma.exercise.findMany({
    where: { isActive: true },
    orderBy: { sortOrder: 'asc' },
    take: TODAY_PLAN_MAX_EXERCISES,
  });

  await prisma.dailyUserExercise.createMany({
    data: activeExercises.map((exercise) => ({
      userId,
      exerciseId: exercise.id,
      planDate,
    })),
    skipDuplicates: true,
  });

  const dailyRows = await prisma.dailyUserExercise.findMany({
    where: {
      userId,
      planDate,
      exerciseId: { in: activeExercises.map((exercise) => exercise.id) },
    },
  });
  const dailyByExerciseId = new Map(dailyRows.map((row) => [row.exerciseId, row]));

  return activeExercises.map((exercise) => {
    const daily = dailyByExerciseId.get(exercise.id);
    if (!daily) {
      throw new Error(`Missing daily plan row for exercise ${exercise.id}`);
    }
    return { exercise, daily };
  });
}

/** Finds or creates today's daily-exercise row for a single exercise (used by complete/skip). */
export async function ensureTodayPlanItem(
  prisma: DB,
  userId: string,
  exerciseId: string,
): Promise<DailyUserExercise> {
  const planDate = utcDayStart(new Date());
  return prisma.dailyUserExercise.upsert({
    where: { userId_exerciseId_planDate: { userId, exerciseId, planDate } },
    create: { userId, exerciseId, planDate },
    update: {},
  });
}
