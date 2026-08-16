import { PrismaClient } from '@prisma/client';
import { v5 as uuidv5 } from 'uuid';
import { serializeScore, MindFitnessScoreJSON } from './serializers';
import { weeklySummaryFor } from '../../domain/insights';

const PERIOD_DAYS: Record<'week' | 'month' | 'three_months', number> = {
  week: 7,
  month: 30,
  three_months: 90,
};

export interface CorrelationInsightJSON {
  id: string;
  title: string;
  description: string;
  strength: number;
}

// Fixed namespace so correlation insight ids are stable across requests/restarts.
const CORRELATION_NAMESPACE = 'b2f6c9d0-6f8b-4c1a-9d3e-2a6f0f7b5b10';

const CORRELATION_INSIGHTS: Omit<CorrelationInsightJSON, 'id'>[] = [
  {
    title: 'Better sleep -> Higher focus',
    description: 'On nights above 7h sleep, your focus rose by 11%.',
    strength: 0.72,
  },
  {
    title: 'Breathing -> Lower stress',
    description: 'Mood volatility decreases after breathwork sessions.',
    strength: 0.61,
  },
  {
    title: 'Journaling -> Steadier mood',
    description: 'Days with a journaling session show fewer low-mood check-ins.',
    strength: 0.54,
  },
];

export async function fetchScores(
  prisma: PrismaClient,
  userId: string,
  period: 'week' | 'month' | 'three_months',
  page?: number,
): Promise<MindFitnessScoreJSON[]> {
  const rangeSize = PERIOD_DAYS[period];
  const skip = ((page ?? 1) - 1) * rangeSize;

  const scores = await prisma.mindFitnessScore.findMany({
    where: { userId },
    orderBy: { date: 'desc' },
    skip,
    take: rangeSize,
  });

  return scores.reverse().map(serializeScore);
}

export function fetchCorrelationInsights(): CorrelationInsightJSON[] {
  return CORRELATION_INSIGHTS.map((insight) => ({
    id: uuidv5(insight.title, CORRELATION_NAMESPACE),
    ...insight,
  }));
}

export async function fetchWeeklySummary(prisma: PrismaClient, userId: string): Promise<string> {
  const user = await prisma.user.findUniqueOrThrow({
    where: { id: userId },
    select: { streakCount: true },
  });

  const sevenDaysAgo = new Date();
  sevenDaysAgo.setUTCDate(sevenDaysAgo.getUTCDate() - 7);

  const recentScores = await prisma.mindFitnessScore.findMany({
    where: { userId, date: { gte: sevenDaysAgo } },
    select: { overallScore: true },
  });

  const averageOverallScore =
    recentScores.length > 0
      ? recentScores.reduce((sum, score) => sum + score.overallScore, 0) / recentScores.length
      : null;

  return weeklySummaryFor(user.streakCount, averageOverallScore);
}
