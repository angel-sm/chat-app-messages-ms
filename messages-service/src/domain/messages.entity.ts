import { v4 as uuid } from 'uuid';

export interface PrimitiveMessage {
  messageId?: string;
  roomId: string;
  senderId: string;
  message: string;
  timestamp: Date;
  isRead: boolean;
}

export class Message {
  constructor(private readonly message: PrimitiveMessage) {}

  static create(message: {
    data: string;
    roomId: string;
    senderId: string;
    timestamp: Date;
    isRead: boolean;
    messageId?: string;
  }): Message {
    return new Message({
      messageId: message.messageId ?? uuid(),
      roomId: message.roomId,
      senderId: message.senderId,
      message: message.data,
      timestamp: message.timestamp,
      isRead: message.isRead,
    });
  }

  toPrimitive(): PrimitiveMessage {
    return this.message;
  }
}
