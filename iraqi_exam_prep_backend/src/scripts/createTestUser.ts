
import "dotenv/config";
import { Role, Subject } from "@prisma/client";
import { prisma } from "../modules/shared/prisma";
import { hashPassword } from "../utils/password";
import { logger } from "../config/logger";

const createTestUser = async () => {
    const email = "admin@iraqi-exam.app";
    const password = "Admin@123456";
    const name = "Admin";

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
        logger.info({ email }, "Test user already exists");
        return existing;
    }

    const passwordHash = await hashPassword(password);
    const user = await prisma.user.create({
        data: {
            email,
            passwordHash,
            name,
            role: Role.STUDENT,
            isPremium: true, // Give premium for testing
            unlockedSubjects: [
                Subject.ARABIC,
                Subject.ENGLISH,
                Subject.COMPUTER,
            ],
        },
    });

    logger.info(
        { email, password },
        "Test user created successfully.",
    );
    return user;
};

createTestUser()
    .then(async () => {
        await prisma.$disconnect();
        process.exit(0);
    })
    .catch(async (error) => {
        logger.error(error, "Failed to create test user");
        await prisma.$disconnect();
        process.exit(1);
    });
