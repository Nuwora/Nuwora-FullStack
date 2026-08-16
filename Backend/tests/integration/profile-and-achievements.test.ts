import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import request from 'supertest';
import { v4 as uuidv4 } from 'uuid';
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

describe('GET /v1/me', () => {
  it('returns the Swift domain display labels for primaryGoals, not the wire identifiers', async () => {
    const { token } = await registerUser();
    await request(app)
      .post('/v1/onboarding')
      .set(...authHeader(token))
      .send(
        validOnboardingPayload({
          primaryGoals: ['focus', 'stress_relief', 'memory', 'resilience'],
        }),
      );

    const response = await request(app)
      .get('/v1/me')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Object.keys(response.body).sort()).toEqual(
      ['id', 'name', 'age', 'primaryGoals', 'joinedAt', 'currentLevel', 'currentStreak'].sort(),
    );
    expect(response.body.primaryGoals).toEqual(['Focus', 'Stress Relief', 'Memory', 'Resilience']);
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/me');
    expect(response.status).toBe(401);
  });
});

describe('GET /v1/me/achievements', () => {
  it('returns a direct JSON array with null unlockedAt for locked achievements', async () => {
    const { token } = await registerUser();
    const response = await request(app)
      .get('/v1/me/achievements')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body.length).toBeGreaterThanOrEqual(4);
    for (const achievement of response.body) {
      expect(Object.keys(achievement).sort()).toEqual(
        ['id', 'title', 'description', 'iconName', 'unlockedAt'].sort(),
      );
      expect(achievement.unlockedAt).toBeNull();
    }
  });

  it('unlocks "First Step" after completing an exercise', async () => {
    const { token } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    await request(app)
      .post(`/v1/exercises/${plan.body[0].id}/complete`)
      .set(...authHeader(token))
      .send({
        performance: 0.9,
        completedAt: '2026-08-16T20:10:00.000Z',
        clientMutationID: uuidv4(),
      });

    const response = await request(app)
      .get('/v1/me/achievements')
      .set(...authHeader(token));

    const firstStep = response.body.find((a: { title: string }) => a.title === 'First Step');
    expect(firstStep.unlockedAt).not.toBeNull();
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/me/achievements');
    expect(response.status).toBe(401);
  });
});
