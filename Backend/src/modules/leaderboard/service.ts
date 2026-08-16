import { PrismaClient } from '@prisma/client';

export interface LeaderboardEntryJSON {
  id: string;
  rank: number;
  alias: string;
  score: number;
}

export async function fetchLeaderboard(
  prisma: PrismaClient,
  limit: number,
): Promise<LeaderboardEntryJSON[]> {
  const users = await prisma.user.findMany({
    orderBy: [{ xp: 'desc' }, { createdAt: 'asc' }],
    take: limit,
    select: { id: true, leaderboardAlias: true, xp: true },
  });

  return users.map((user, index) => ({
    id: user.id,
    rank: index + 1,
    alias: user.leaderboardAlias,
    score: user.xp,
  }));
}
