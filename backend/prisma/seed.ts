import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Minimal seed — add fixture users/contacts as needed for local dev.
  await prisma.user.upsert({
    where: { phone: '+8801712345678' },
    update: {},
    create: {
      phone: '+8801712345678',
      name: 'Seed User',
      isActive: true,
    },
  });

  // eslint-disable-next-line no-console
  console.log('seed: complete');
}

main()
  .catch((err) => {
    // eslint-disable-next-line no-console
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
