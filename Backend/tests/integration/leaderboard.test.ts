import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import request from 'supertest';
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

describe('GET /v1/leaderboard', () => {
  it('returns a direct JSON array ranked by score descending, respecting limit', async () => {
    await testPrisma.user.createMany({
      data: [
        { id: '11111111-1111-1111-1111-111111111111', leaderboardAlias: 'AliasOne', xp: 500 },
        { id: '22222222-2222-2222-2222-222222222222', leaderboardAlias: 'AliasTwo', xp: 900 },
        { id: '33333333-3333-3333-3333-333333333333', leaderboardAlias: 'AliasThree', xp: 100 },
      ],
    });
    const { token } = await registerUser();

    const response = await request(app)
      .get('/v1/leaderboard?limit=3')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body).toHaveLength(3);
    expect(response.body[0]).toEqual({
      id: '22222222-2222-2222-2222-222222222222',
      rank: 1,
      alias: 'AliasTwo',
      score: 900,
    });
    expect(response.body.map((e: { rank: number }) => e.rank)).toEqual([1, 2, 3]);
  });

  it('defaults to a small limit when none is given', async () => {
    const { token } = await registerUser();
    const response = await request(app)
      .get('/v1/leaderboard')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(response.body.length).toBeLessThanOrEqual(3);
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/leaderboard?limit=3');
    expect(response.status).toBe(401);
  });
});
