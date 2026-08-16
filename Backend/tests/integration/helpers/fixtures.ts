export function validOnboardingPayload(overrides: Record<string, unknown> = {}) {
  return {
    name: 'Maya',
    age: 29,
    primaryGoals: ['focus', 'stress_relief'],
    assessmentAnswers: [3, 4, 5, 2, 4],
    connectedWearables: ['apple_watch'],
    initialScores: { overall: 72, cognitive: 80, biometric: 65, mood: 71 },
    ...overrides,
  };
}
