import { v4 as uuidv4 } from 'uuid';
import request from 'supertest';
import { createApp } from '../../../src/app';

export const app = createApp();

export interface AuthedUser {
  token: string;
  userId: string;
  deviceID: string;
}

/** Registers a fresh anonymous user (unique deviceID) and returns its bearer token. */
export async function registerUser(): Promise<AuthedUser> {
  const deviceID = uuidv4();
  const response = await request(app).post('/v1/auth/anonymous').send({ deviceID });
  if (response.status !== 200) {
    throw new Error(
      `Failed to register test user: ${response.status} ${JSON.stringify(response.body)}`,
    );
  }
  return { token: response.body.accessToken, userId: response.body.user.id, deviceID };
}

export function authHeader(token: string): [string, string] {
  return ['Authorization', `Bearer ${token}`];
}
