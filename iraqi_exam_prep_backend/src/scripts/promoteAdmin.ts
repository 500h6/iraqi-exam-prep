import { PrismaClient } from '@prisma/client';
import { normalizePhoneNumber, getPhoneVariants } from '../utils/phoneUtils';
import * as dotenv from 'dotenv';
dotenv.config();

const prisma = new PrismaClient();

async function promoteAdmin() {
    // Get phone from CLI argument or use default
    const rawPhone = process.argv[2] || '9647810110034';
    const normalizedPhone = normalizePhoneNumber(rawPhone);
    const phoneVariants = getPhoneVariants(rawPhone);

    console.log(`🔍 Looking for user with phone: ${rawPhone}`);
    console.log(`   Normalized: ${normalizedPhone}`);
    console.log(`   Variants: ${phoneVariants.join(', ')}`);

    try {
        // Find user with any phone variant
        const user = await prisma.user.findFirst({
            where: { phone: { in: phoneVariants } },
        });

        if (!user) {
            console.error('❌ User not found! They must register first via the app.');
            return;
        }

        // Promote to ADMIN
        const updatedUser = await prisma.user.update({
            where: { id: user.id },
            data: { role: 'ADMIN' },
        });

        console.log(`✅ User "${updatedUser.name}" (${updatedUser.phone}) is now an ADMIN!`);
    } catch (error) {
        console.error('❌ Error promoting user:', error);
    } finally {
        await prisma.$disconnect();
    }
}

promoteAdmin();
