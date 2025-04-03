import { PrimitiveMessage } from '@/domain/messages.entity';
import { MessagesRepository } from '@/domain/messages.repository';

export class PrismaDbRepository extends MessagesRepository {
  async create(message: PrimitiveMessage): Promise<void> {
    throw new Error('Method not implemented.');
  }
  async list(): Promise<PrimitiveMessage[]> {
    throw new Error('Method not implemented.');
  }
}
