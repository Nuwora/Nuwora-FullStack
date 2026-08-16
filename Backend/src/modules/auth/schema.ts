import { z } from 'zod';

export const anonymousAuthSchema = z.object({
  deviceID: z.string().uuid('deviceID must be a UUID string'),
});

const emailSchema = z
  .string()
  .trim()
  .min(1, 'email is required')
  .email('email must be a valid email address')
  .transform((value) => value.toLowerCase());

const passwordSchema = z
  .string()
  .min(8, 'password must be at least 8 characters')
  .max(72, 'password must be at most 72 characters');

export const registerSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});

export const loginSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});

export type AnonymousAuthInput = z.infer<typeof anonymousAuthSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
