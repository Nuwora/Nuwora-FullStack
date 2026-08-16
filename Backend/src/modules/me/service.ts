import { PrismaClient } from '@prisma/client';
import { levelForXP } from '../../domain/xp';
import { goalDisplayLabel } from '../../domain/goals';

export interface UserJSON {
  id: string;
  name: string;
  age: number;
  primaryGoals: string[];
  joinedAt: Date;
  currentLevel: number;
  currentStreak: number;
}

export interface AchievementJSON {
  id: string;
  title: string;
  description: string;
  iconName: string;
  unlockedAt: Date | null;
}

export async function loadProfile(prisma: PrismaClient, userId: string): Promise<UserJSON> {
  const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
  return {
    id: user.id,
    name: user.name ?? '',
    age: user.age ?? 0,
    primaryGoals: user.primaryGoals.map(goalDisplayLabel),
    joinedAt: user.createdAt,
    currentLevel: levelForXP(user.xp),
    currentStreak: user.streakCount,
  };
}

export async function loadAchievements(
  prisma: PrismaClient,
  userId: string,
): Promise<AchievementJSON[]> {
  const achievements = await prisma.achievement.findMany({
    orderBy: { sortOrder: 'asc' },
    include: {
      userAchievements: {
        where: { userId },
        select: { unlockedAt: true },
      },
    },
  });

  return achievements.map((achievement) => ({
    id: achievement.id,
    title: achievement.title,
    description: achievement.description,
    iconName: achievement.iconName,
    unlockedAt: achievement.userAchievements[0]?.unlockedAt ?? null,
  }));
}
