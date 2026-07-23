import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function run() {
  try {
    const users = await prisma.user.findMany({
      where: {
        OR: [
          { name: { contains: 'hussein', mode: 'insensitive' } },
          { phone: { contains: '7810011034' } },
        ],
      },
    });

    if (users.length === 0) {
      console.log('No users found matching hussein or 7810011034.');
      return;
    }

    console.log(`Found ${users.length} matching users. Promoting all to ADMIN...`);

    for (const user of users) {
      await prisma.user.update({
        where: { id: user.id },
        data: { role: 'ADMIN' },
      });
      console.log(`Promoted user: ${user.name} (Phone: ${user.phone}) to ADMIN.`);
    }

    console.log('✅ Done!');
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await prisma.$disconnect();
  }
}

run();
