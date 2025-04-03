import { PrismaClient as Prisma } from '@prisma/client';

class PrismaClient {
  private static instance: Prisma;

  private constructor() {}

  public static getInsanance(): Prisma {
    if (!PrismaClient.instance) {
      PrismaClient.instance = new Prisma();
    }
    return PrismaClient.instance;
  }
}

export default PrismaClient;
