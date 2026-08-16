import { describe, expect, it } from 'vitest';
import { DeterministicCoachResponder } from '../../src/domain/coach';

describe('DeterministicCoachResponder', () => {
  const responder = new DeterministicCoachResponder();

  it('returns the same reply for the same content and persona', () => {
    const first = responder.reply('I need help focusing', 'zen_monk');
    const second = responder.reply('I need help focusing', 'zen_monk');
    expect(first).toBe(second);
  });

  it('returns a non-empty reply for every known persona', () => {
    for (const persona of ['zen_monk', 'peak_performer', 'neuroscientist'] as const) {
      const reply = responder.reply('hello', persona);
      expect(reply.length).toBeGreaterThan(0);
    }
  });

  it('can vary the reply by persona for the same content', () => {
    const zen = responder.reply('same message', 'zen_monk');
    const peak = responder.reply('same message', 'peak_performer');
    // Personas draw from disjoint phrase pools, so replies never collide.
    expect(zen).not.toBe(peak);
  });
});
