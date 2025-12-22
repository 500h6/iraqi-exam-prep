
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function verify() {
    console.log('🔍 Verifying question counts...');

    const counts = await prisma.examQuestion.groupBy({
        by: ['subject'],
        _count: {
            id: true,
        },
    });

    console.log('📊 Question Counts per Subject:');
    counts.forEach((c) => {
        console.log(`- ${c.subject}: ${c._count.id}`);
    });

    await prisma.$disconnect();
}

verify().catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
});
