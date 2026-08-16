import { describe, expect, it } from 'vitest';
import { levelForXP, xpProgressForXP, XP_PER_LEVEL } from '../../src/domain/xp';

describe('levelForXP', () => {
  it('starts new users at level 1', () => {
    expect(levelForXP(0)).toBe(1);
    expect(levelForXP(1)).toBe(1);
    expect(levelForXP(499)).toBe(1);
  });

  it('advances a level every 500 xp', () => {
    expect(levelForXP(500)).toBe(2);
    expect(levelForXP(999)).toBe(2);
    expect(levelForXP(1000)).toBe(3);
    expect(levelForXP(4 * XP_PER_LEVEL)).toBe(5);
  });
});

describe('xpProgressForXP', () => {
  it('is 0 at the start of a level', () => {
    expect(xpProgressForXP(0)).toBe(0);
    expect(xpProgressForXP(500)).toBe(0);
  });

  it('is a fraction of the way through the current level', () => {
    expect(xpProgressForXP(250)).toBeCloseTo(0.5);
    expect(xpProgressForXP(310)).toBeCloseTo(0.62);
  });

  it('never leaves the 0...1 range', () => {
    expect(xpProgressForXP(0)).toBeGreaterThanOrEqual(0);
    expect(xpProgressForXP(999999)).toBeLessThanOrEqual(1);
  });
});
