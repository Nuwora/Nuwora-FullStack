import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { validateBody, validateQuery } from '../../middleware/validate';
import {
  listMessagesQuerySchema,
  sendMessageSchema,
  ListMessagesQuery,
  SendMessageInput,
} from './schema';
import { listMessages, sendMessage } from './service';

export const coachRouter = Router();

coachRouter.get(
  '/coach/messages',
  validateQuery(listMessagesQuerySchema),
  async (req, res, next) => {
    try {
      const query = req.validatedQuery as ListMessagesQuery;
      const messages = await listMessages(prisma, req.userId, query);
      res.status(200).json(messages);
    } catch (error) {
      next(error);
    }
  },
);

coachRouter.post('/coach/messages', validateBody(sendMessageSchema), async (req, res, next) => {
  try {
    const message = await sendMessage(prisma, req.userId, req.body as SendMessageInput);
    res.status(200).json(message);
  } catch (error) {
    next(error);
  }
});
