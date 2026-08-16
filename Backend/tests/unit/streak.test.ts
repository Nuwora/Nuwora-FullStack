import { describe, expect, it } from 'vitest';
import { nextStreak } from '../../src/domain/streak';

const day = (isoDate: string): Date => new Date(`${isoDate}T00:00:00.000Z`);

describe('nextStreak', () => {
  it('starts a first-ever completion at streak 1', () => {
    const result = nextStreak(0, null, day('2026-08-16'));
    expect(result.streakCount).toBe(1);
    expect(result.lastExerciseCompletedOn).toEqual(day('2026-08-16'));
  });

  it('does not change the streak for a second completion on the same UTC day', () => {
    const result = nextStreak(1, day('2026-08-16'), day('2026-08-16T23:59:00.000Z'));
    expect(result.streakCount).toBe(1);
  });

  it('increments the streak on the very next consecutive UTC day', () => {
    const result = nextStreak(3, day('2026-08-16'), day('2026-08-17'));
    expect(result.streakCount).toBe(4);
    expect(result.lastExerciseCompletedOn).toEqual(day('2026-08-17'));
  });

  it('resets the streak to 1 after a gap of more than one day', () => {
    const result = nextStreak(5, day('2026-08-10'), day('2026-08-16'));
    expect(result.streakCount).toBe(1);
    expect(result.lastExerciseCompletedOn).toEqual(day('2026-08-16'));
  });

  it('treats a completion earlier than the recorded day as a reset, never a negative streak', () => {
    const result = nextStreak(5, day('2026-08-16'), day('2026-08-10'));
    expect(result.streakCount).toBe(1);
  });
});
