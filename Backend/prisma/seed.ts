import { PrismaClient } from '@prisma/client';
import { seedExercises, seedAchievements, seedId } from './seedCatalog';

const prisma = new PrismaClient();

interface DemoUserSeed {
  alias: string;
  xp: number;
}

// Safe, non-identifying aliases only — no real names or handles.
const DEMO_LEADERBOARD_USERS: DemoUserSeed[] = [
  { alias: 'ZenFalcon', xp: 2810 },
  { alias: 'NovaPulse', xp: 2730 },
  { alias: 'CalmRider', xp: 2645 },
  { alias: 'FocusForge', xp: 2510 },
  { alias: 'QuietRiver', xp: 2370 },
  { alias: 'AuroraMind', xp: 2298 },
];

const SCORE_HISTORY_DAYS = 90;

function utcDayStart(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

async function seedDemoLeaderboardUsers(): Promise<string> {
  let scoreHistoryUserId = '';

  for (const demoUser of DEMO_LEADERBOARD_USERS) {
    const userId = seedId(`demo-user:${demoUser.alias}`);
    const deviceID = seedId(`demo-device:${demoUser.alias}`);

    await prisma.user.upsert({
      where: { id: userId },
      create: {
        id: userId,
        leaderboardAlias: demoUser.alias,
        xp: demoUser.xp,
        deviceIdentity: { create: { deviceID } },
      },
      update: { leaderboardAlias: demoUser.alias, xp: demoUser.xp },
    });

    if (demoUser.alias === 'ZenFalcon') {
      scoreHistoryUserId = userId;
    }
  }

  return scoreHistoryUserId;
}

async function seedScoreHistory(userId: string): Promise<void> {
  if (!userId) return;

  const today = utcDayStart(new Date());
  for (let offset = 0; offset < SCORE_HISTORY_DAYS; offset += 1) {
    const date = new Date(today);
    date.setUTCDate(date.getUTCDate() - offset);

    const cognitiveScore = clamp(55 + ((offset * 11) % 30), 0, 100);
    const biometricScore = clamp(50 + ((offset * 13) % 30), 0, 100);
    const moodScore = clamp(52 + ((offset * 17) % 30), 0, 100);
    const overallScore = clamp(
      Math.round(cognitiveScore * 0.4 + biometricScore * 0.3 + moodScore * 0.3),
      0,
      100,
    );

    await prisma.mindFitnessScore.upsert({
      where: { userId_date: { userId, date } },
      create: {
        userId,
        date,
        overallScore,
        cognitiveScore,
        biometricScore,
        moodScore,
        focusSubscore: cognitiveScore,
        calmSubscore: moodScore,
        energySubscore: biometricScore,
      },
      update: {
        overallScore,
        cognitiveScore,
        biometricScore,
        moodScore,
        focusSubscore: cognitiveScore,
        calmSubscore: moodScore,
        energySubscore: biometricScore,
      },
    });
  }
}

async function main(): Promise<void> {
  await seedExercises(prisma);
  await seedAchievements(prisma);
  const scoreHistoryUserId = await seedDemoLeaderboardUsers();
  await seedScoreHistory(scoreHistoryUserId);
  // eslint-disable-next-line no-console
  console.log('Seed complete.');
}

main()
  .catch((error) => {
    // eslint-disable-next-line no-console
    console.error('Seed failed:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
