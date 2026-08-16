import { PrismaClient } from '@prisma/client';
import { TxClient } from '../lib/idempotency';

type DB = PrismaClient | TxClient;

/**
 * Shown as the first thing a brand-new user sees in the Coach tab, so the
 * screen never opens empty. Persona-neutral (zen_monk is just a default
 * sender voice, not a user preference — onboarding hasn't happened yet).
 */
const WELCOME_MESSAGES: string[] = [
  "Welcome to Nuwora. I'm your coach — think of me as a steady, judgment-free companion for building focus, calm, and resilience.",
  "Whenever you're stressed, stuck, or just want a quick reset, tell me what's going on and I'll suggest something small to try.",
];

export const WELCOME_MESSAGE_COUNT = WELCOME_MESSAGES.length;

export async function seedWelcomeMessages(db: DB, userId: string): Promise<void> {
  await db.chatMessage.createMany({
    data: WELCOME_MESSAGES.map((content) => ({
      userId,
      content,
      sender: 'coach' as const,
      persona: 'zen_monk' as const,
    })),
  });
}
