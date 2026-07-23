import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function run() {
  const users = await prisma.user.findMany({ where: { phone: { contains: '7810011034' } } });
  console.log(users);
  await prisma.$disconnect();
}
run();
