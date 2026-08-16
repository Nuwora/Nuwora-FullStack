import { MindFitnessScore } from '@prisma/client';

export interface MindFitnessScoreJSON {
  id: string;
  date: Date;
  overallScore: number;
  cognitiveScore: number;
  biometricScore: number;
  moodScore: number;
  focusSubscore: number;
  calmSubscore: number;
  energySubscore: number;
}

export function serializeScore(score: MindFitnessScore): MindFitnessScoreJSON {
  return {
    id: score.id,
    date: score.date,
    overallScore: score.overallScore,
    cognitiveScore: score.cognitiveScore,
    biometricScore: score.biometricScore,
    moodScore: score.moodScore,
    focusSubscore: score.focusSubscore,
    calmSubscore: score.calmSubscore,
    energySubscore: score.energySubscore,
  };
}
