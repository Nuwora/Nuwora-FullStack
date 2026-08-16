import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import request from 'supertest';
import { app, authHeader, registerUser } from './helpers/app';
import { ensureTestDatabaseMigrated, resetUserData, seedCatalog, testPrisma } from './helpers/db';
import { validOnboardingPayload } from './helpers/fixtures';

beforeAll(async () => {
  ensureTestDatabaseMigrated();
  await resetUserData();
  await seedCatalog();
});

beforeEach(async () => {
  await resetUserData();
});

afterAll(async () => {
  await testPrisma.$disconnect();
});

async function onboardedUser() {
  const user = await registerUser();
  await request(app)
    .post('/v1/onboarding')
    .set(...authHeader(user.token))
    .send(validOnboardingPayload());
  return user;
}

describe('GET /v1/dashboard', () => {
  it('returns exactly the contract-shaped object with correct field names', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/dashboard')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(false);
    expect(Object.keys(response.body).sort()).toEqual(
      [
        'score',
        'planPreview',
        'streakCount',
        'currentLevel',
        'xpProgress',
        'aiInsight',
        'lastSyncDate',
      ].sort(),
    );

    const { score } = response.body;
    expect(Object.keys(score).sort()).toEqual(
      [
        'id',
        'date',
        'overallScore',
        'cognitiveScore',
        'biometricScore',
        'moodScore',
        'focusSubscore',
        'calmSubscore',
        'energySubscore',
      ].sort(),
    );
    expect(score.overallScore).toBe(72);
    expect(score.cognitiveScore).toBe(80);
    expect(score.biometricScore).toBe(65);
    expect(score.moodScore).toBe(71);
  });

  it('caps planPreview at three exercises', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/dashboard')
      .set(...authHeader(token));

    expect(response.body.planPreview.length).toBeLessThanOrEqual(3);
    expect(response.body.planPreview.length).toBeGreaterThan(0);
  });

  it('reports xpProgress within 0...1 and level starting at 1', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/dashboard')
      .set(...authHeader(token));

    expect(response.body.currentLevel).toBe(1);
    expect(response.body.xpProgress).toBeGreaterThanOrEqual(0);
    expect(response.body.xpProgress).toBeLessThanOrEqual(1);
    expect(response.body.streakCount).toBe(0);
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/dashboard');
    expect(response.status).toBe(401);
  });
});
