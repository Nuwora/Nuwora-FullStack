import { PrismaClient } from '@prisma/client';
import { levelForXP, xpProgressForXP } from '../../domain/xp';
import { aiInsightFor } from '../../domain/insights';
import { ensureTodayPlan } from '../plans/service';
import { serializeExercise, ExerciseJSON } from '../exercises/serializers';
import { serializeScore, MindFitnessScoreJSON } from '../analytics/serializers';
import { AppError } from '../../lib/errors';

export interface DashboardSnapshotJSON {
  score: MindFitnessScoreJSON;
  planPreview: ExerciseJSON[];
  streakCount: number;
  currentLevel: number;
  xpProgress: number;
  aiInsight: string;
  lastSyncDate: Date;
}

const DASHBOARD_PLAN_PREVIEW_SIZE = 3;

export async function loadDashboard(
  prisma: PrismaClient,
  userId: string,
): Promise<DashboardSnapshotJSON> {
  const user = await prisma.user.findUniqueOrThrow({
    where: { id: userId },
    select: { xp: true, streakCount: true },
  });

  const latestScore = await prisma.mindFitnessScore.findFirst({
    where: { userId },
    orderBy: { date: 'desc' },
  });
  if (!latestScore) {
    throw AppError.notFound('Complete onboarding before loading the dashboard.');
  }

  const planItems = await ensureTodayPlan(prisma, userId);
  const xpProgress = xpProgressForXP(user.xp);

  return {
    score: serializeScore(latestScore),
    planPreview: planItems
      .slice(0, DASHBOARD_PLAN_PREVIEW_SIZE)
      .map((item) => serializeExercise(item.exercise, item.daily.status)),
    streakCount: user.streakCount,
    currentLevel: levelForXP(user.xp),
    xpProgress,
    aiInsight: aiInsightFor(user.streakCount, xpProgress),
    lastSyncDate: new Date(),
  };
}
