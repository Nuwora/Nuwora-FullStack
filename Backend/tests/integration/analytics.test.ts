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

describe('GET /v1/analytics/scores', () => {
  it('returns a direct JSON array of score objects for each valid period', async () => {
    const { token } = await onboardedUser();

    for (const period of ['week', 'month', 'three_months']) {
      const response = await request(app)
        .get(`/v1/analytics/scores?period=${period}`)
        .set(...authHeader(token));

      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThanOrEqual(1);
      expect(Object.keys(response.body[0]).sort()).toEqual(
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
    }
  });

  it('rejects an invalid period', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/analytics/scores?period=not_a_period')
      .set(...authHeader(token));

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('requires a period query parameter', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/analytics/scores')
      .set(...authHeader(token));

    expect(response.status).toBe(400);
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/analytics/scores?period=week');
    expect(response.status).toBe(401);
  });
});

describe('GET /v1/analytics/correlations', () => {
  it('returns a direct JSON array with strength in 0...1', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/analytics/correlations')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body.length).toBeGreaterThan(0);
    for (const insight of response.body) {
      expect(Object.keys(insight).sort()).toEqual(
        ['id', 'title', 'description', 'strength'].sort(),
      );
      expect(insight.strength).toBeGreaterThanOrEqual(0);
      expect(insight.strength).toBeLessThanOrEqual(1);
    }
  });
});

describe('GET /v1/analytics/weekly-summary', () => {
  it('returns an object with a summary string', async () => {
    const { token } = await onboardedUser();
    const response = await request(app)
      .get('/v1/analytics/weekly-summary')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ summary: expect.any(String) });
  });
});
