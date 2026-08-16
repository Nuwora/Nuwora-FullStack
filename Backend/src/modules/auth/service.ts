import { Prisma, PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { generateLeaderboardAlias } from '../../domain/alias';
import { seedWelcomeMessages } from '../../domain/welcomeMessages';
import { AppError } from '../../lib/errors';

const BCRYPT_SALT_ROUNDS = 10;
const UNIQUE_CONSTRAINT_ERROR = 'P2002';
const GENERIC_LOGIN_FAILURE_MESSAGE = 'Invalid email or password.';
// A precomputed, valid bcrypt hash with no matching plaintext. Used to make a
// nonexistent-email login attempt take the same time as a wrong-password one.
const DUMMY_PASSWORD_HASH = '$2b$10$I0JXglMNTkMkydxT1LZABeiP.8uUhhsyWO8742WZPaHbIR/WvHYAm';

export interface ResolvedUser {
  userId: string;
  isNewUser: boolean;
}

/** Same deviceID always resolves to the same user; a new device creates a new user. */
export async function findOrCreateUserByDeviceId(
  prisma: PrismaClient,
  deviceID: string,
): Promise<ResolvedUser> {
  const existing = await prisma.deviceIdentity.findUnique({
    where: { deviceID },
    select: { userId: true },
  });
  if (existing) {
    return { userId: existing.userId, isNewUser: false };
  }

  const newUserId = uuidv4();
  try {
    await prisma.$transaction(async (tx) => {
      await tx.user.create({
        data: {
          id: newUserId,
          leaderboardAlias: generateLeaderboardAlias(newUserId),
          deviceIdentity: {
            create: { deviceID },
          },
        },
      });
      await seedWelcomeMessages(tx, newUserId);
    });
    return { userId: newUserId, isNewUser: true };
  } catch (error) {
    // A concurrent request for the same deviceID raced us and won; resolve to their user.
    const racedExisting = await prisma.deviceIdentity.findUnique({
      where: { deviceID },
      select: { userId: true },
    });
    if (racedExisting) {
      return { userId: racedExisting.userId, isNewUser: false };
    }
    throw error;
  }
}

/** Creates a brand-new email/password account. Rejects if the email is already registered. */
export async function registerUser(
  prisma: PrismaClient,
  email: string,
  password: string,
): Promise<ResolvedUser> {
  const passwordHash = await bcrypt.hash(password, BCRYPT_SALT_ROUNDS);
  const newUserId = uuidv4();

  try {
    await prisma.$transaction(async (tx) => {
      await tx.user.create({
        data: {
          id: newUserId,
          email,
          passwordHash,
          leaderboardAlias: generateLeaderboardAlias(newUserId),
        },
      });
      await seedWelcomeMessages(tx, newUserId);
    });
    return { userId: newUserId, isNewUser: true };
  } catch (error) {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === UNIQUE_CONSTRAINT_ERROR
    ) {
      throw AppError.conflict('An account with this email already exists.');
    }
    throw error;
  }
}

/** Validates email/password credentials and resolves the matching user. */
export async function loginUser(
  prisma: PrismaClient,
  email: string,
  password: string,
): Promise<ResolvedUser> {
  const user = await prisma.user.findUnique({
    where: { email },
    select: { id: true, passwordHash: true },
  });

  if (!user || !user.passwordHash) {
    await bcrypt.compare(password, DUMMY_PASSWORD_HASH);
    throw AppError.unauthorized(GENERIC_LOGIN_FAILURE_MESSAGE);
  }

  const passwordMatches = await bcrypt.compare(password, user.passwordHash);
  if (!passwordMatches) {
    throw AppError.unauthorized(GENERIC_LOGIN_FAILURE_MESSAGE);
  }

  return { userId: user.id, isNewUser: false };
}
