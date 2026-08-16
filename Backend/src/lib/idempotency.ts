import { Prisma, PrismaClient } from '@prisma/client';

export type TxClient = Prisma.TransactionClient;

const UNIQUE_CONSTRAINT_ERROR = 'P2002';

/**
 * Runs `mutate` at most once per (userId, clientMutationID). If the mutation
 * already ran, returns the previously stored response instead of re-applying
 * side effects (XP, streaks, messages, ...).
 */
export async function withIdempotency<T>(
  prisma: PrismaClient,
  params: {
    userId: string;
    clientMutationID: string;
    mutationType: string;
  },
  mutate: (tx: TxClient) => Promise<T>,
): Promise<T> {
  const existing = await prisma.processedMutation.findUnique({
    where: {
      userId_clientMutationID: {
        userId: params.userId,
        clientMutationID: params.clientMutationID,
      },
    },
  });

  if (existing) {
    return (existing.responseBody as unknown as T) ?? (undefined as T);
  }

  try {
    return await prisma.$transaction(async (tx) => {
      const result = await mutate(tx);
      await tx.processedMutation.create({
        data: {
          userId: params.userId,
          clientMutationID: params.clientMutationID,
          mutationType: params.mutationType,
          responseBody: (result ?? null) as unknown as Prisma.InputJsonValue,
        },
      });
      return result;
    });
  } catch (error) {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === UNIQUE_CONSTRAINT_ERROR
    ) {
      // Concurrent duplicate request raced us; the other one won, replay its result.
      const raced = await prisma.processedMutation.findUnique({
        where: {
          userId_clientMutationID: {
            userId: params.userId,
            clientMutationID: params.clientMutationID,
          },
        },
      });
      if (raced) {
        return (raced.responseBody as unknown as T) ?? (undefined as T);
      }
    }
    throw error;
  }
}
