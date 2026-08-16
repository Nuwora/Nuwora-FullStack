import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import request from 'supertest';
import { v4 as uuidv4 } from 'uuid';
import { app, authHeader, registerUser } from './helpers/app';
import { ensureTestDatabaseMigrated, resetUserData, seedCatalog, testPrisma } from './helpers/db';

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

describe('GET /v1/plans/today', () => {
  it('returns a direct JSON array with 3 to 5 exercises shaped per the contract', async () => {
    const { token } = await registerUser();
    const response = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body.length).toBeGreaterThanOrEqual(3);
    expect(response.body.length).toBeLessThanOrEqual(5);

    for (const exercise of response.body) {
      expect(Object.keys(exercise).sort()).toEqual(
        [
          'id',
          'title',
          'subtitle',
          'type',
          'durationSeconds',
          'difficulty',
          'xpReward',
          'isCompleted',
        ].sort(),
      );
      expect(['breathing', 'cognitive', 'mindfulness', 'focus', 'journaling']).toContain(
        exercise.type,
      );
      expect(exercise.isCompleted).toBe(false);
    }
  });

  it('is stable across repeated calls on the same UTC day', async () => {
    const { token } = await registerUser();
    const first = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const second = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));

    expect(second.body.map((e: { id: string }) => e.id)).toEqual(
      first.body.map((e: { id: string }) => e.id),
    );
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/plans/today');
    expect(response.status).toBe(401);
  });
});

describe('POST /v1/exercises/:id/complete', () => {
  it('awards XP and starts a streak on first completion, returns 204', async () => {
    const { token, userId } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const exercise = plan.body[0];

    const response = await request(app)
      .post(`/v1/exercises/${exercise.id}/complete`)
      .set(...authHeader(token))
      .send({
        performance: 0.86,
        completedAt: '2026-08-16T20:10:00.000Z',
        clientMutationID: uuidv4(),
      });

    expect(response.status).toBe(204);
    expect(response.body).toEqual({});

    const user = await testPrisma.user.findUniqueOrThrow({ where: { id: userId } });
    expect(user.xp).toBe(exercise.xpReward);
    expect(user.streakCount).toBe(1);
  });

  it('does not award XP or advance the streak twice for the same clientMutationID', async () => {
    const { token, userId } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const exercise = plan.body[0];
    const mutationID = uuidv4();
    const body = {
      performance: 0.86,
      completedAt: '2026-08-16T20:10:00.000Z',
      clientMutationID: mutationID,
    };

    await request(app)
      .post(`/v1/exercises/${exercise.id}/complete`)
      .set(...authHeader(token))
      .send(body);
    await request(app)
      .post(`/v1/exercises/${exercise.id}/complete`)
      .set(...authHeader(token))
      .send(body);

    const user = await testPrisma.user.findUniqueOrThrow({ where: { id: userId } });
    expect(user.xp).toBe(exercise.xpReward);
    expect(user.streakCount).toBe(1);
  });

  it('marks the exercise completed in a later plans/today call', async () => {
    const { token } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const exercise = plan.body[0];

    await request(app)
      .post(`/v1/exercises/${exercise.id}/complete`)
      .set(...authHeader(token))
      .send({
        performance: 0.5,
        completedAt: '2026-08-16T20:10:00.000Z',
        clientMutationID: uuidv4(),
      });

    const updatedPlan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const updatedExercise = updatedPlan.body.find((e: { id: string }) => e.id === exercise.id);
    expect(updatedExercise.isCompleted).toBe(true);
  });

  it('returns 404 for an unknown exercise id', async () => {
    const { token } = await registerUser();
    const response = await request(app)
      .post('/v1/exercises/00000000-0000-0000-0000-000000000000/complete')
      .set(...authHeader(token))
      .send({
        performance: 0.5,
        completedAt: '2026-08-16T20:10:00.000Z',
        clientMutationID: uuidv4(),
      });

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('NOT_FOUND');
  });

  it.each([
    ['performance below range', { performance: -0.1 }],
    ['performance above range', { performance: 1.1 }],
    ['missing clientMutationID', { clientMutationID: undefined }],
  ])('rejects invalid input: %s', async (_label, overrides) => {
    const { token } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const exercise = plan.body[0];

    const response = await request(app)
      .post(`/v1/exercises/${exercise.id}/complete`)
      .set(...authHeader(token))
      .send({
        performance: 0.5,
        completedAt: '2026-08-16T20:10:00.000Z',
        clientMutationID: uuidv4(),
        ...overrides,
      });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('requires authentication', async () => {
    const response = await request(app)
      .post('/v1/exercises/00000000-0000-0000-0000-000000000000/complete')
      .send({
        performance: 0.5,
        completedAt: '2026-08-16T20:10:00.000Z',
        clientMutationID: uuidv4(),
      });
    expect(response.status).toBe(401);
  });
});

describe('POST /v1/exercises/:id/skip', () => {
  it('marks the exercise skipped without awarding XP, returns 204', async () => {
    const { token, userId } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const exercise = plan.body[0];

    const response = await request(app)
      .post(`/v1/exercises/${exercise.id}/skip`)
      .set(...authHeader(token))
      .send({ skippedAt: '2026-08-16T20:10:00.000Z', clientMutationID: uuidv4() });

    expect(response.status).toBe(204);

    const user = await testPrisma.user.findUniqueOrThrow({ where: { id: userId } });
    expect(user.xp).toBe(0);
    expect(user.streakCount).toBe(0);

    const updatedPlan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const updatedExercise = updatedPlan.body.find((e: { id: string }) => e.id === exercise.id);
    expect(updatedExercise.isCompleted).toBe(false);
  });

  it('is idempotent for repeated calls with the same clientMutationID', async () => {
    const { token } = await registerUser();
    const plan = await request(app)
      .get('/v1/plans/today')
      .set(...authHeader(token));
    const exercise = plan.body[0];
    const body = { skippedAt: '2026-08-16T20:10:00.000Z', clientMutationID: uuidv4() };

    const first = await request(app)
      .post(`/v1/exercises/${exercise.id}/skip`)
      .set(...authHeader(token))
      .send(body);
    const second = await request(app)
      .post(`/v1/exercises/${exercise.id}/skip`)
      .set(...authHeader(token))
      .send(body);

    expect(first.status).toBe(204);
    expect(second.status).toBe(204);
  });

  it('requires authentication', async () => {
    const response = await request(app)
      .post('/v1/exercises/00000000-0000-0000-0000-000000000000/skip')
      .send({ skippedAt: '2026-08-16T20:10:00.000Z', clientMutationID: uuidv4() });
    expect(response.status).toBe(401);
  });
});
