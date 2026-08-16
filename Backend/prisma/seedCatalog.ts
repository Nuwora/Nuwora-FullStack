import { PrismaClient } from '@prisma/client';
import { v5 as uuidv5 } from 'uuid';

// Fixed namespace so every seeded id is stable across re-runs (idempotent seed).
const SEED_NAMESPACE = 'b6f2a7d4-6a8e-4b8d-9e4b-4b0a9a7a3ad0';
export const seedId = (name: string): string => uuidv5(name, SEED_NAMESPACE);

export interface ExerciseSeed {
  title: string;
  subtitle: string;
  type: 'breathing' | 'cognitive' | 'mindfulness' | 'focus' | 'journaling';
  durationSeconds: number;
  difficulty: number;
  xpReward: number;
  sortOrder: number;
}

export const EXERCISES: ExerciseSeed[] = [
  {
    title: 'Breathing Reset',
    subtitle: '2-minute downshift',
    type: 'breathing',
    durationSeconds: 120,
    difficulty: 2,
    xpReward: 60,
    sortOrder: 1,
  },
  {
    title: 'Deep Focus',
    subtitle: 'Sustained attention interval',
    type: 'focus',
    durationSeconds: 600,
    difficulty: 3,
    xpReward: 90,
    sortOrder: 2,
  },
  {
    title: 'Stroop Sprint',
    subtitle: 'Quick-fire pattern switching',
    type: 'cognitive',
    durationSeconds: 360,
    difficulty: 4,
    xpReward: 80,
    sortOrder: 3,
  },
  {
    title: 'Mindful Reset',
    subtitle: 'Present-moment awareness',
    type: 'mindfulness',
    durationSeconds: 300,
    difficulty: 2,
    xpReward: 60,
    sortOrder: 4,
  },
  {
    title: 'Reflective Journal',
    subtitle: 'Structured evening reflection',
    type: 'journaling',
    durationSeconds: 420,
    difficulty: 2,
    xpReward: 65,
    sortOrder: 5,
  },
];

export interface AchievementSeed {
  title: string;
  description: string;
  iconName: string;
  criterionKey: string;
  sortOrder: number;
}

export const ACHIEVEMENTS: AchievementSeed[] = [
  {
    title: 'First Step',
    description: 'Complete your first exercise.',
    iconName: 'figure.walk',
    criterionKey: 'first_exercise',
    sortOrder: 1,
  },
  {
    title: 'Streak Starter',
    description: 'Reach a 3-day streak.',
    iconName: 'flame.fill',
    criterionKey: 'streak_3',
    sortOrder: 2,
  },
  {
    title: 'Mood Tracker',
    description: 'Log your mood 5 times.',
    iconName: 'face.smiling',
    criterionKey: 'mood_5',
    sortOrder: 3,
  },
  {
    title: 'Level Up',
    description: 'Reach level 2.',
    iconName: 'star.fill',
    criterionKey: 'level_2',
    sortOrder: 4,
  },
];

export async function seedExercises(prisma: PrismaClient): Promise<void> {
  for (const exercise of EXERCISES) {
    await prisma.exercise.upsert({
      where: { id: seedId(`exercise:${exercise.title}`) },
      create: { id: seedId(`exercise:${exercise.title}`), ...exercise },
      update: { ...exercise },
    });
  }
}

export async function seedAchievements(prisma: PrismaClient): Promise<void> {
  for (const achievement of ACHIEVEMENTS) {
    await prisma.achievement.upsert({
      where: { criterionKey: achievement.criterionKey },
      create: { id: seedId(`achievement:${achievement.criterionKey}`), ...achievement },
      update: { ...achievement },
    });
  }
}
