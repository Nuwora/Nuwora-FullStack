import { PrismaClient } from '@prisma/client';
import { withIdempotency } from '../../lib/idempotency';
import { coachResponder } from '../../domain/coach';
import { serializeChatMessage, ChatMessageJSON } from './serializers';
import { ListMessagesQuery, SendMessageInput } from './schema';

export async function listMessages(
  prisma: PrismaClient,
  userId: string,
  query: ListMessagesQuery,
): Promise<ChatMessageJSON[]> {
  let cursorSequence: number | undefined;
  if (query.cursor) {
    const cursorMessage = await prisma.chatMessage.findFirst({
      where: { id: query.cursor, userId },
      select: { sequence: true },
    });
    cursorSequence = cursorMessage?.sequence;
  }

  const messages = await prisma.chatMessage.findMany({
    where: {
      userId,
      ...(cursorSequence !== undefined ? { sequence: { lt: cursorSequence } } : {}),
    },
    orderBy: { sequence: 'desc' },
    take: query.limit,
  });

  return messages.reverse().map(serializeChatMessage);
}

export async function sendMessage(
  prisma: PrismaClient,
  userId: string,
  input: SendMessageInput,
): Promise<ChatMessageJSON> {
  return withIdempotency(
    prisma,
    { userId, clientMutationID: input.clientMutationID, mutationType: 'coach_message' },
    async (tx) => {
      await tx.chatMessage.create({
        data: { userId, content: input.content, sender: 'user' },
      });

      const replyContent = coachResponder.reply(input.content, input.persona);
      const coachMessage = await tx.chatMessage.create({
        data: { userId, content: replyContent, sender: 'coach', persona: input.persona },
      });

      return serializeChatMessage(coachMessage);
    },
  );
}
