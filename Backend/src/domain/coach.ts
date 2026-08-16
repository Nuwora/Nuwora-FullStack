import { CoachPersona } from '@prisma/client';

/**
 * Behind an interface so a real LLM-backed provider can replace
 * DeterministicCoachResponder later without touching the route layer.
 */
export interface CoachResponder {
  reply(content: string, persona: CoachPersona): string;
}

const PERSONA_OPENERS: Record<CoachPersona, string[]> = {
  zen_monk: [
    "Let's take one slow breath together.",
    'Notice the ground beneath you before we continue.',
    'Stillness first, then clarity.',
  ],
  peak_performer: [
    "Let's turn this into your next rep.",
    'Good — momentum starts with one clear action.',
    "You've got the reps in you. Let's use them.",
  ],
  neuroscientist: [
    'Your brain responds well to small, repeatable cues.',
    "Here's what the pattern in your data suggests.",
    'A short, focused interval will regulate this quickly.',
  ],
};

const PERSONA_CLOSERS: Record<CoachPersona, string[]> = {
  zen_monk: [
    'Try a two-minute breathing reset and see how the moment shifts.',
    'Return to this whenever the noise builds up.',
  ],
  peak_performer: [
    'Pick one exercise from today’s plan and go all in for the next five minutes.',
    "Small consistent wins compound. Let's log one now.",
  ],
  neuroscientist: [
    'A brief mindfulness or breathing exercise should measurably lower that load.',
    'Track how you feel afterward — the data will confirm the shift.',
  ],
};

function pickDeterministic<T>(items: T[], seed: string): T {
  let hash = 0;
  for (let i = 0; i < seed.length; i += 1) {
    hash = (hash * 31 + seed.charCodeAt(i)) >>> 0;
  }
  const item = items[hash % items.length];
  if (item === undefined) {
    throw new Error('pickDeterministic requires a non-empty array');
  }
  return item;
}

export class DeterministicCoachResponder implements CoachResponder {
  reply(content: string, persona: CoachPersona): string {
    const trimmed = content.trim();
    const opener = pickDeterministic(PERSONA_OPENERS[persona], trimmed || persona);
    const closerSeed = trimmed.length > 0 ? `${trimmed}-closer` : persona;
    const closer = pickDeterministic(PERSONA_CLOSERS[persona], closerSeed);
    return `${opener} ${closer}`;
  }
}

export const coachResponder: CoachResponder = new DeterministicCoachResponder();
