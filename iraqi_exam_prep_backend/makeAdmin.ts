import { PrismaClient } from '@prisma/client';
import { normalizePhoneNumber } from './src/utils/phoneUtils';

const prisma = new PrismaClient();

async function makeAdmin() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.error('Please provide a phone number. Example: npx ts-node makeAdmin.ts 07812345678');
    process.exit(1);
  }

  const rawPhone = args.join('');
  const phone = normalizePhoneNumber(rawPhone);

  console.log(`Looking for user with normalized phone: ${phone}`);

  try {
    const user = await prisma.user.findUnique({
      where: { phone },
    });

    if (!user) {
      console.error('User not found. Please make sure you have registered in the app first.');
      process.exit(1);
    }

    const updatedUser = await prisma.user.update({
      where: { phone },
      data: { role: 'ADMIN' },
    });

    console.log(`Success! User ${updatedUser.name} (${updatedUser.phone}) is now an ADMIN.`);
  } catch (error) {
    console.error('Error updating user:', error);
  } finally {
    await prisma.$disconnect();
  }
}

makeAdmin();
