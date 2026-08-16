import { describe, expect, it } from 'vitest';
import { generateLeaderboardAlias } from '../../src/domain/alias';

describe('generateLeaderboardAlias', () => {
  it('is deterministic for the same seed', () => {
    const seed = '11111111-1111-1111-1111-111111111111';
    expect(generateLeaderboardAlias(seed)).toBe(generateLeaderboardAlias(seed));
  });

  it('does not echo the raw seed back (safe, non-identifying alias)', () => {
    const seed = '22222222-2222-2222-2222-222222222222';
    expect(generateLeaderboardAlias(seed)).not.toContain(seed);
  });

  it('produces an AdjectiveNoun-shaped alias', () => {
    const alias = generateLeaderboardAlias('some-user-id');
    expect(alias).toMatch(/^[A-Z][a-z]+[A-Z][a-z]+$/);
  });
});
