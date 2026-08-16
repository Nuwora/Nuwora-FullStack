import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import request from 'supertest';
import { v4 as uuidv4 } from 'uuid';
import { app } from './helpers/app';
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

describe('POST /v1/auth/anonymous', () => {
  it('creates a new user for an unseen deviceID and marks it as new', async () => {
    const deviceID = uuidv4();
    const response = await request(app).post('/v1/auth/anonymous').send({ deviceID });

    expect(response.status).toBe(200);
    expect(response.body.accessToken).toEqual(expect.any(String));
    expect(response.body.user.isNewUser).toBe(true);
    expect(response.body.user.id).toEqual(expect.any(String));
  });

  it('resolves the same deviceID to the same user on repeated calls', async () => {
    const deviceID = uuidv4();
    const first = await request(app).post('/v1/auth/anonymous').send({ deviceID });
    const second = await request(app).post('/v1/auth/anonymous').send({ deviceID });

    expect(first.body.user.id).toBe(second.body.user.id);
    expect(first.body.user.isNewUser).toBe(true);
    expect(second.body.user.isNewUser).toBe(false);
  });

  it('rejects a missing deviceID with a standard validation error', async () => {
    const response = await request(app).post('/v1/auth/anonymous').send({});

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(response.body.error.requestID).toEqual(expect.any(String));
  });

  it('rejects a non-UUID deviceID', async () => {
    const response = await request(app).post('/v1/auth/anonymous').send({ deviceID: 'not-a-uuid' });
    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});

describe('POST /v1/auth/register', () => {
  const uniqueEmail = (): string => `${uuidv4()}@example.com`;

  it('creates a new account and returns a bearer token', async () => {
    const email = uniqueEmail();
    const response = await request(app)
      .post('/v1/auth/register')
      .send({ email, password: 'correct-horse-123' });

    expect(response.status).toBe(200);
    expect(response.body.accessToken).toEqual(expect.any(String));
    expect(response.body.user.isNewUser).toBe(true);
    expect(response.body.user.id).toEqual(expect.any(String));
  });

  it('seeds welcome coach messages for the new account', async () => {
    const email = uniqueEmail();
    const response = await request(app)
      .post('/v1/auth/register')
      .send({ email, password: 'correct-horse-123' });

    const messages = await testPrisma.chatMessage.findMany({
      where: { userId: response.body.user.id },
    });
    expect(messages.length).toBeGreaterThan(0);
    expect(messages.every((m) => m.sender === 'coach')).toBe(true);
  });

  it('rejects a duplicate email with 409 CONFLICT', async () => {
    const email = uniqueEmail();
    await request(app).post('/v1/auth/register').send({ email, password: 'correct-horse-123' });
    const response = await request(app)
      .post('/v1/auth/register')
      .send({ email, password: 'a-different-password' });

    expect(response.status).toBe(409);
    expect(response.body.error.code).toBe('CONFLICT');
    expect(response.body.error.requestID).toEqual(expect.any(String));
  });

  it('treats email as case-insensitive for uniqueness', async () => {
    const email = uniqueEmail();
    await request(app).post('/v1/auth/register').send({ email, password: 'correct-horse-123' });
    const response = await request(app)
      .post('/v1/auth/register')
      .send({ email: email.toUpperCase(), password: 'correct-horse-123' });

    expect(response.status).toBe(409);
  });

  it.each([
    ['invalid email', { email: 'not-an-email', password: 'correct-horse-123' }],
    ['missing email', { password: 'correct-horse-123' }],
    ['password too short', { email: uniqueEmail(), password: 'short1' }],
    ['missing password', { email: uniqueEmail() }],
  ])('rejects invalid input: %s', async (_label, body) => {
    const response = await request(app).post('/v1/auth/register').send(body);
    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});

describe('POST /v1/auth/login', () => {
  it('logs in with correct credentials and returns isNewUser: false', async () => {
    const email = `${uuidv4()}@example.com`;
    const password = 'correct-horse-123';
    await request(app).post('/v1/auth/register').send({ email, password });

    const response = await request(app).post('/v1/auth/login').send({ email, password });

    expect(response.status).toBe(200);
    expect(response.body.accessToken).toEqual(expect.any(String));
    expect(response.body.user.isNewUser).toBe(false);
  });

  it('is case-insensitive on email', async () => {
    const email = `${uuidv4()}@example.com`;
    const password = 'correct-horse-123';
    await request(app).post('/v1/auth/register').send({ email, password });

    const response = await request(app)
      .post('/v1/auth/login')
      .send({ email: email.toUpperCase(), password });

    expect(response.status).toBe(200);
  });

  it('rejects a wrong password with a generic 401 message', async () => {
    const email = `${uuidv4()}@example.com`;
    await request(app).post('/v1/auth/register').send({ email, password: 'correct-horse-123' });

    const response = await request(app)
      .post('/v1/auth/login')
      .send({ email, password: 'totally-wrong-password' });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
    expect(response.body.error.message).toBe('Invalid email or password.');
  });

  it('rejects a nonexistent email with the same generic 401 message', async () => {
    const response = await request(app)
      .post('/v1/auth/login')
      .send({ email: 'nobody-here@example.com', password: 'whatever-password' });

    expect(response.status).toBe(401);
    expect(response.body.error.message).toBe('Invalid email or password.');
  });

  it.each([
    ['invalid email', { email: 'not-an-email', password: 'correct-horse-123' }],
    ['missing password', { email: 'someone@example.com' }],
  ])('rejects invalid input: %s', async (_label, body) => {
    const response = await request(app).post('/v1/auth/login').send(body);
    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});

describe('Bearer auth middleware', () => {
  it('rejects protected routes with no Authorization header', async () => {
    const response = await request(app).get('/v1/me');
    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
    expect(response.body.error.requestID).toEqual(expect.any(String));
  });

  it('rejects protected routes with a malformed bearer token', async () => {
    const response = await request(app).get('/v1/me').set('Authorization', 'Bearer not-a-real-jwt');
    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('rejects an Authorization header without the Bearer scheme', async () => {
    const response = await request(app).get('/v1/me').set('Authorization', 'Basic abc123');
    expect(response.status).toBe(401);
  });
});

describe('GET /health', () => {
  it('is reachable without authentication and outside /v1', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });
});
