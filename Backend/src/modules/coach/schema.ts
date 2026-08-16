import { z } from 'zod';

export const coachPersonaSchema = z.enum(['zen_monk', 'peak_performer', 'neuroscientist']);

export const listMessagesQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(200).default(100),
  cursor: z.string().uuid('cursor must be a UUID string').optional(),
});

export const sendMessageSchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, 'content must not be empty')
    .max(2000, 'content must be at most 2000 characters'),
  persona: coachPersonaSchema,
  clientMutationID: z.string().uuid('clientMutationID must be a UUID string'),
});

export type ListMessagesQuery = z.infer<typeof listMessagesQuerySchema>;
export type SendMessageInput = z.infer<typeof sendMessageSchema>;
