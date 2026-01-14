import { PrismaClient, Subject } from "@prisma/client";

const prisma = new PrismaClient();

async function removeDuplicates(subject?: Subject) {
    console.log(`Searching for duplicates${subject ? ` in ${subject}` : ""}...`);

    // 1. Fetch questions
    const where = subject ? { subject } : {};
    const questions = await prisma.examQuestion.findMany({
        where,
        select: {
            id: true,
            questionText: true,
            subject: true,
            // We'll use questionText + Subject to identify duplicates
        },
    });

    console.log(`Total questions found: ${questions.length}`);

    // 2. Identify duplicates
    const seen = new Map<string, string>(); // Key -> First ID
    const toDelete: string[] = [];

    for (const q of questions) {
        // Normalize text (trim, lowercase) to catch slight variations
        const key = `${q.subject}_${q.questionText.trim().toLowerCase()}`;

        if (seen.has(key)) {
            toDelete.push(q.id);
            // console.log(`Found duplicate: ${q.questionText.substring(0, 30)}... (Original: ${seen.get(key)}, Duplicate: ${q.id})`);
        } else {
            seen.set(key, q.id);
        }
    }

    // 3. Delete duplicates
    console.log(`Found ${toDelete.length} duplicates to delete.`);

    if (toDelete.length > 0) {
        const result = await prisma.examQuestion.deleteMany({
            where: {
                id: {
                    in: toDelete,
                },
            },
        });
        console.log(`Deleted ${result.count} duplicates successfully.`);
    } else {
        console.log("No duplicates found to delete.");
    }
}

// Run for English specifically as requested
removeDuplicates('ENGLISH')
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
