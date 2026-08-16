import { z } from 'zod';

export const goalSchema = z.enum(['focus', 'stress_relief', 'memory', 'resilience']);
export const wearableSchema = z.enum(['apple_watch', 'oura', 'fitbit', 'whoop']);

export const onboardingSchema = z.object({
  name: z
    .string()
    .trim()
    .min(2, 'name must be at least 2 characters')
    .max(100, 'name must be at most 100 characters'),
  age: z
    .number()
    .int('age must be an integer')
    .min(13, 'age must be at least 13')
    .max(100, 'age must be at most 100'),
  primaryGoals: z.array(goalSchema).min(1, 'primaryGoals must contain at least one goal'),
  assessmentAnswers: z
    .array(z.number().int().min(1).max(5))
    .length(5, 'assessmentAnswers must contain exactly 5 answers'),
  connectedWearables: z.array(wearableSchema),
  initialScores: z.object({
    overall: z.number().int().min(0).max(100),
    cognitive: z.number().int().min(0).max(100),
    biometric: z.number().int().min(0).max(100),
    mood: z.number().int().min(0).max(100),
  }),
});

export type OnboardingInput = z.infer<typeof onboardingSchema>;
