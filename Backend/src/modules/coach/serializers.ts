import { ChatMessage } from '@prisma/client';

export interface ChatMessageJSON {
  id: string;
  content: string;
  sender: string;
  timestamp: Date;
}

export function serializeChatMessage(message: ChatMessage): ChatMessageJSON {
  return {
    id: message.id,
    content: message.content,
    sender: message.sender,
    timestamp: message.createdAt,
  };
}
