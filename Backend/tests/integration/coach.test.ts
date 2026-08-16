import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import request from 'supertest';
import { v4 as uuidv4 } from 'uuid';
import { app, authHeader, registerUser } from './helpers/app';
import { ensureTestDatabaseMigrated, resetUserData, seedCatalog, testPrisma } from './helpers/db';
import { WELCOME_MESSAGE_COUNT } from '../../src/domain/welcomeMessages';

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

describe('POST /v1/coach/messages', () => {
  it('persists both the user message and a coach reply, returning the coach message', async () => {
    const { token, userId } = await registerUser();
    const response = await request(app)
      .post('/v1/coach/messages')
      .set(...authHeader(token))
      .send({ content: 'I need help focusing', persona: 'zen_monk', clientMutationID: uuidv4() });

    expect(response.status).toBe(200);
    expect(Object.keys(response.body).sort()).toEqual(
      ['id', 'content', 'sender', 'timestamp'].sort(),
    );
    expect(response.body.sender).toBe('coach');
    expect(response.body.content.length).toBeGreaterThan(0);

    const messages = await testPrisma.chatMessage.findMany({ where: { userId } });
    expect(messages).toHaveLength(WELCOME_MESSAGE_COUNT + 2);
    const senders = messages.map((m) => m.sender);
    expect(senders.filter((sender) => sender === 'user')).toHaveLength(1);
    expect(senders.filter((sender) => sender === 'coach')).toHaveLength(WELCOME_MESSAGE_COUNT + 1);
  });

  it('does not duplicate messages when retried with the same clientMutationID', async () => {
    const { token, userId } = await registerUser();
    const body = {
      content: 'I need help focusing',
      persona: 'zen_monk',
      clientMutationID: uuidv4(),
    };

    const first = await request(app)
      .post('/v1/coach/messages')
      .set(...authHeader(token))
      .send(body);
    const second = await request(app)
      .post('/v1/coach/messages')
      .set(...authHeader(token))
      .send(body);

    expect(second.body).toEqual(first.body);
    const messages = await testPrisma.chatMessage.findMany({ where: { userId } });
    expect(messages).toHaveLength(WELCOME_MESSAGE_COUNT + 2);
  });

  it.each([
    ['empty content', { content: '' }],
    ['invalid persona', { persona: 'not_a_persona' }],
    ['missing clientMutationID', { clientMutationID: undefined }],
  ])('rejects invalid input: %s', async (_label, overrides) => {
    const { token } = await registerUser();
    const response = await request(app)
      .post('/v1/coach/messages')
      .set(...authHeader(token))
      .send({ content: 'hello', persona: 'zen_monk', clientMutationID: uuidv4(), ...overrides });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('requires authentication', async () => {
    const response = await request(app)
      .post('/v1/coach/messages')
      .send({ content: 'hi', persona: 'zen_monk', clientMutationID: uuidv4() });
    expect(response.status).toBe(401);
  });
});

describe('GET /v1/coach/messages', () => {
  it('returns a direct JSON array ordered oldest to newest', async () => {
    const { token } = await registerUser();
    await request(app)
      .post('/v1/coach/messages')
      .set(...authHeader(token))
      .send({ content: 'first', persona: 'zen_monk', clientMutationID: uuidv4() });
    await request(app)
      .post('/v1/coach/messages')
      .set(...authHeader(token))
      .send({ content: 'second', persona: 'peak_performer', clientMutationID: uuidv4() });

    const response = await request(app)
      .get('/v1/coach/messages?limit=100')
      .set(...authHeader(token));

    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body).toHaveLength(WELCOME_MESSAGE_COUNT + 4);
    expect(response.body[WELCOME_MESSAGE_COUNT].content).toBe('first');
    expect(response.body[WELCOME_MESSAGE_COUNT + 2].content).toBe('second');

    const timestamps = response.body.map((m: { timestamp: string }) =>
      new Date(m.timestamp).getTime(),
    );
    const sorted = [...timestamps].sort((a, b) => a - b);
    expect(timestamps).toEqual(sorted);
  });

  it('requires authentication', async () => {
    const response = await request(app).get('/v1/coach/messages');
    expect(response.status).toBe(401);
  });
});
