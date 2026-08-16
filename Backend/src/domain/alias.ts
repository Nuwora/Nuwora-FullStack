const ADJECTIVES = [
  'Mindful',
  'Serene',
  'Focused',
  'Calm',
  'Steady',
  'Bright',
  'Quiet',
  'Bold',
  'Clear',
  'Gentle',
  'Vivid',
  'Zen',
];

const NOUNS = [
  'Maya',
  'Falcon',
  'River',
  'Fox',
  'Nova',
  'Rider',
  'Forge',
  'Aurora',
  'Pulse',
  'Sage',
  'Summit',
  'Ember',
];

function hashString(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash * 31 + value.charCodeAt(i)) >>> 0;
  }
  return hash;
}

/** Deterministically derives a safe, non-identifying display alias from a stable seed (e.g. user id). */
export function generateLeaderboardAlias(seed: string): string {
  const hash = hashString(seed);
  const adjective = ADJECTIVES[hash % ADJECTIVES.length];
  const noun = NOUNS[Math.floor(hash / ADJECTIVES.length) % NOUNS.length];
  return `${adjective}${noun}`;
}
