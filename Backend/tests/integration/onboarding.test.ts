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

describe('POST /v1/onboarding', () => {
  it('accepts a valid submission and returns 204 with no body', async () => {
    const { token } = await registerUser();
    const response = await request(app)
      .post('/v1/onboarding')
      .set(...authHeader(token))
      .send(validOnboardingPayload());

    expect(response.status).toBe(204);
    expect(response.body).toEqual({});
  });

  it('persists the submission so a later profile load reflects it', async () => {
    const { token } = await registerUser();
    await request(app)
      .post('/v1/onboarding')
      .set(...authHeader(token))
      .send(validOnboardingPayload({ name: 'Riley', age: 41 }));

    const profile = await request(app)
      .get('/v1/me')
      .set(...authHeader(token));

    expect(profile.body.name).toBe('Riley');
    expect(profile.body.age).toBe(41);
  });

  it('treats a repeated submission as an update, not a duplicate', async () => {
    const { token, userId } = await registerUser();
    await request(app)
      .post('/v1/onboarding')
      .set(...authHeader(token))
      .send(validOnboardingPayload({ name: 'First Name' }));
    await request(app)
      .post('/v1/onboarding')
      .set(...authHeader(token))
      .send(validOnboardingPayload({ name: 'Second Name' }));

    const assessments = await testPrisma.onboardingAssessment.findMany({ where: { userId } });
    expect(assessments).toHaveLength(1);

    const profile = await request(app)
      .get('/v1/me')
      .set(...authHeader(token));
    expect(profile.body.name).toBe('Second Name');
  });

  it('requires authentication', async () => {
    const response = await request(app).post('/v1/onboarding').send(validOnboardingPayload());
    expect(response.status).toBe(401);
  });

  it.each([
    ['name too short', { name: 'A' }],
    ['age below minimum', { age: 5 }],
    ['age above maximum', { age: 150 }],
    ['empty primaryGoals', { primaryGoals: [] }],
    ['invalid goal value', { primaryGoals: ['not_a_goal'] }],
    ['wrong number of assessment answers', { assessmentAnswers: [1, 2, 3] }],
    ['assessment answer out of range', { assessmentAnswers: [1, 2, 3, 4, 9] }],
    ['invalid wearable value', { connectedWearables: ['not_a_wearable'] }],
    [
      'score out of range',
      { initialScores: { overall: 200, cognitive: 80, biometric: 65, mood: 71 } },
    ],
  ])('rejects invalid input: %s', async (_label, overrides) => {
    const { token } = await registerUser();
    const response = await request(app)
      .post('/v1/onboarding')
      .set(...authHeader(token))
      .send(validOnboardingPayload(overrides));

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(response.body.error.requestID).toEqual(expect.any(String));
  });
});
