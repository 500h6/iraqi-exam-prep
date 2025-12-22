import "dotenv/config";
import { Role, Subject } from "@prisma/client";
import { prisma } from "../modules/shared/prisma";
import { hashPassword } from "../utils/password";
import { env } from "../config/env";
import { logger } from "../config/logger";

const createOrUpdateAdmin = async () => {
  const email = env.adminEmail.toLowerCase();
  const password = env.adminPassword;
  const name = env.adminName;

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    if (existing.role !== Role.ADMIN) {
      await prisma.user.update({
        where: { id: existing.id },
        data: { role: Role.ADMIN, isPremium: true },
      });
      logger.info({ email }, "Existing user promoted to admin");
    } else {
      logger.info({ email }, "Admin user already exists");
    }
    return existing;
  }

  const passwordHash = await hashPassword(password);
  const admin = await prisma.user.create({
    data: {
      email,
      passwordHash,
      name,
      role: Role.ADMIN,
      isPremium: true,
      unlockedSubjects: [
        Subject.ARABIC,
        Subject.ENGLISH,
        Subject.COMPUTER,
      ],
    },
  });

  logger.info(
    { email, password },
    "Admin user created. Please store the credentials securely.",
  );
  return admin;
};

createOrUpdateAdmin()
  .then(async () => {
    await prisma.$disconnect();
    process.exit(0);
  })
  .catch(async (error) => {
    logger.error(error, "Failed to create admin user");
    await prisma.$disconnect();
    process.exit(1);
  });
