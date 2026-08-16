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

function moodPayload(overrides: Record<string, unknown> = {}) {
  return {
    mood: 4,
    occurredAt: '2026-08-16T20:10:00.000Z',
    clientMutationID: uuidv4(),
    ...overrides,
  };
}

describe('POST /v1/moods', () => {
  it('accepts a valid mood and returns 204 with no body', async () => {
    const { token } = await registerUser();
    const response = await request(app)
      .post('/v1/moods')
      .set(...authHeader(token))
      .send(moodPayload());

    expect(response.status).toBe(204);
    expect(response.body).toEqual({});
  });

  it('persists exactly one entry per clientMutationID even when retried', async () => {
    const { token, userId } = await registerUser();
    const payload = moodPayload();

    await request(app)
      .post('/v1/moods')
      .set(...authHeader(token))
      .send(payload);
    await request(app)
      .post('/v1/moods')
      .set(...authHeader(token))
      .send(payload);

    const entries = await testPrisma.moodEntry.findMany({ where: { userId } });
    expect(entries).toHaveLength(1);
  });

  it('creates a second entry for a different clientMutationID', async () => {
    const { token, userId } = await registerUser();
    await request(app)
      .post('/v1/moods')
      .set(...authHeader(token))
      .send(moodPayload());
    await request(app)
      .post('/v1/moods')
      .set(...authHeader(token))
      .send(moodPayload());

    const entries = await testPrisma.moodEntry.findMany({ where: { userId } });
    expect(entries).toHaveLength(2);
  });

  it.each([
    ['mood below range', { mood: 0 }],
    ['mood above range', { mood: 6 }],
    ['mood not an integer', { mood: 3.5 }],
    ['missing clientMutationID', { clientMutationID: undefined }],
    ['invalid occurredAt', { occurredAt: 'not-a-date' }],
  ])('rejects invalid input: %s', async (_label, overrides) => {
    const { token } = await registerUser();
    const response = await request(app)
      .post('/v1/moods')
      .set(...authHeader(token))
      .send(moodPayload(overrides));

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('requires authentication', async () => {
    const response = await request(app).post('/v1/moods').send(moodPayload());
    expect(response.status).toBe(401);
  });
});
