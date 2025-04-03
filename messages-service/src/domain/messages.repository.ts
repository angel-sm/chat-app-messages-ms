import { PrimitiveMessage } from "./messages.entity";

export abstract class MessagesRepository {
  abstract create(message: PrimitiveMessage): Promise<void>;
  abstract list(): Promise<PrimitiveMessage[]>;
}
