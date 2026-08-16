import { describe, expect, it, vi } from 'vitest';
import { withIdempotency } from '../../src/lib/idempotency';

/**
 * A minimal in-memory stand-in for the slice of PrismaClient that
 * withIdempotency depends on: processedMutation.findUnique/create and
 * $transaction. This lets the idempotency contract be verified without a
 * database.
 */
function createFakePrisma() {
  const rows = new Map<string, { responseBody: unknown }>();
  const key = (userId: string, clientMutationID: string): string => `${userId}:${clientMutationID}`;

  const processedMutation = {
    findUnique: vi.fn(
      async ({
        where,
      }: {
        where: { userId_clientMutationID: { userId: string; clientMutationID: string } };
      }) => {
        const { userId, clientMutationID } = where.userId_clientMutationID;
        return rows.get(key(userId, clientMutationID)) ?? null;
      },
    ),
    create: vi.fn(
      async ({
        data,
      }: {
        data: { userId: string; clientMutationID: string; responseBody: unknown };
      }) => {
        rows.set(key(data.userId, data.clientMutationID), { responseBody: data.responseBody });
        return data;
      },
    ),
  };

  const tx: { processedMutation: typeof processedMutation } = { processedMutation };

  const prisma = {
    processedMutation,
    $transaction: vi.fn(
      async (callback: (tx: { processedMutation: typeof processedMutation }) => Promise<unknown>) =>
        callback(tx),
    ),
  };

  return prisma;
}

describe('withIdempotency', () => {
  it('runs the mutation on the first call for a given mutation id', async () => {
    const prisma = createFakePrisma();
    const mutate = vi.fn(async () => ({ ok: true }));

    const result = await withIdempotency(
      prisma as never,
      { userId: 'user-1', clientMutationID: 'mut-1', mutationType: 'test' },
      mutate,
    );

    expect(mutate).toHaveBeenCalledTimes(1);
    expect(result).toEqual({ ok: true });
  });

  it('does not re-run the mutation for a repeated (userId, clientMutationID) pair', async () => {
    const prisma = createFakePrisma();
    const mutate = vi.fn(async () => ({ ok: true }));
    const params = { userId: 'user-1', clientMutationID: 'mut-1', mutationType: 'test' };

    await withIdempotency(prisma as never, params, mutate);
    const secondResult = await withIdempotency(prisma as never, params, mutate);

    expect(mutate).toHaveBeenCalledTimes(1);
    expect(secondResult).toEqual({ ok: true });
  });

  it('treats different clientMutationIDs for the same user as independent mutations', async () => {
    const prisma = createFakePrisma();
    const mutate = vi.fn(async () => ({ ok: true }));

    await withIdempotency(
      prisma as never,
      { userId: 'user-1', clientMutationID: 'mut-1', mutationType: 'test' },
      mutate,
    );
    await withIdempotency(
      prisma as never,
      { userId: 'user-1', clientMutationID: 'mut-2', mutationType: 'test' },
      mutate,
    );

    expect(mutate).toHaveBeenCalledTimes(2);
  });

  it('treats the same clientMutationID for different users as independent mutations', async () => {
    const prisma = createFakePrisma();
    const mutate = vi.fn(async () => ({ ok: true }));

    await withIdempotency(
      prisma as never,
      { userId: 'user-1', clientMutationID: 'mut-1', mutationType: 'test' },
      mutate,
    );
    await withIdempotency(
      prisma as never,
      { userId: 'user-2', clientMutationID: 'mut-1', mutationType: 'test' },
      mutate,
    );

    expect(mutate).toHaveBeenCalledTimes(2);
  });
});
