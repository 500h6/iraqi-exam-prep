
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function listUsers() {
    console.log('🔍 Fetching users...');

    const users = await prisma.user.findMany({
        select: {
            email: true,
            name: true,
            role: true,
            isPremium: true,
        },
    });

    if (users.length === 0) {
        console.log('No users found.');
    } else {
        console.table(users);
    }

    await prisma.$disconnect();
}

listUsers().catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
});
