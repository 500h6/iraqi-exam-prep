
import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
dotenv.config();

const prisma = new PrismaClient();

async function promoteAdmin() {
    const phone = '9647810011034'; // User's phone

    try {
        const user = await prisma.user.update({
            where: { phone },
            data: { role: 'ADMIN' },
        });
        console.log(`✅ User ${user.name} (${user.phone}) is now an ADMIN!`);
    } catch (error) {
        console.error('❌ Error promoting user:', error);
    } finally {
        await prisma.$disconnect();
    }
}

promoteAdmin();
