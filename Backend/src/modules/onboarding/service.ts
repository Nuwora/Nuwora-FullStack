import { PrismaClient } from '@prisma/client';
import { utcDayStart } from '../../domain/dates';
import { OnboardingInput } from './schema';

export async function submitOnboarding(
  prisma: PrismaClient,
  userId: string,
  input: OnboardingInput,
): Promise<void> {
  const today = utcDayStart(new Date());

  await prisma.$transaction([
    prisma.user.update({
      where: { id: userId },
      data: {
        name: input.name,
        age: input.age,
        primaryGoals: input.primaryGoals,
        connectedWearables: input.connectedWearables,
        onboardingCompletedAt: new Date(),
      },
    }),
    prisma.onboardingAssessment.upsert({
      where: { userId },
      create: {
        userId,
        answers: input.assessmentAnswers,
        overallScore: input.initialScores.overall,
        cognitiveScore: input.initialScores.cognitive,
        biometricScore: input.initialScores.biometric,
        moodScore: input.initialScores.mood,
      },
      update: {
        answers: input.assessmentAnswers,
        overallScore: input.initialScores.overall,
        cognitiveScore: input.initialScores.cognitive,
        biometricScore: input.initialScores.biometric,
        moodScore: input.initialScores.mood,
      },
    }),
    prisma.mindFitnessScore.upsert({
      where: { userId_date: { userId, date: today } },
      create: {
        userId,
        date: today,
        overallScore: input.initialScores.overall,
        cognitiveScore: input.initialScores.cognitive,
        biometricScore: input.initialScores.biometric,
        moodScore: input.initialScores.mood,
        focusSubscore: input.initialScores.cognitive,
        calmSubscore: input.initialScores.mood,
        energySubscore: input.initialScores.biometric,
      },
      update: {
        overallScore: input.initialScores.overall,
        cognitiveScore: input.initialScores.cognitive,
        biometricScore: input.initialScores.biometric,
        moodScore: input.initialScores.mood,
        focusSubscore: input.initialScores.cognitive,
        calmSubscore: input.initialScores.mood,
        energySubscore: input.initialScores.biometric,
      },
    }),
  ]);
}
