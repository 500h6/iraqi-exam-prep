import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
const prisma = new PrismaClient();
async function run() {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        phone: true,
        name: true,
        role: true,
      }
    });
    fs.writeFileSync('users_dump.json', JSON.stringify(users, null, 2));
    console.log('Successfully dumped users to users_dump.json');
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await prisma.$disconnect();
  }
}
run();
