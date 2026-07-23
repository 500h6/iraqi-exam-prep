import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function run() {
  try {
    const users = await prisma.user.findMany({
      where: {
        phone: { contains: '7765972402' },
      },
    });

    for (const user of users) {
      await prisma.user.update({
        where: { id: user.id },
        data: { role: 'STUDENT' },
      });
      console.log(`Demoted user: ${user.name} (Phone: ${user.phone}) to STUDENT.`);
    }

    console.log('✅ Done!');
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await prisma.$disconnect();
  }
}

run();
