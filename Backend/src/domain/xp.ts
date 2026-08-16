export const XP_PER_LEVEL = 500;

export function levelForXP(xp: number): number {
  return 1 + Math.floor(xp / XP_PER_LEVEL);
}

/** Fraction of the way through the current level, in 0...1. */
export function xpProgressForXP(xp: number): number {
  const progress = (xp % XP_PER_LEVEL) / XP_PER_LEVEL;
  return Math.min(1, Math.max(0, progress));
}
