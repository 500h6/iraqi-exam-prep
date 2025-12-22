
import { PrismaClient, Subject } from '@prisma/client';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();

interface QuestionJson {
    text: string;
    options: string[];
    correctAnswer: string;
}

const FILES = [
    { name: 'english_questions.json', subject: Subject.ENGLISH },
    { name: 'arabic_questions.json', subject: Subject.ARABIC },
    { name: 'computer_questions.json', subject: Subject.COMPUTER },
];

async function importQuestions() {
    console.log('🚀 Starting question import...');

    for (const file of FILES) {
        const filePath = path.join(process.cwd(), '..', file.name); // Assumes backend is running from its root, and files are in parent dir

        if (!fs.existsSync(filePath)) {
            console.warn(`⚠️  File not found: ${filePath}, skipping...`);
            continue;
        }

        console.log(`\n📂 Processing ${file.name} (${file.subject})...`);

        try {
            const rawData = fs.readFileSync(filePath, 'utf-8');
            const questions: QuestionJson[] = JSON.parse(rawData);

            let importedCount = 0;
            let skippedCount = 0;

            for (const q of questions) {
                // Find index of correct answer
                const correctIndex = q.options.indexOf(q.correctAnswer);

                if (correctIndex === -1) {
                    console.warn(`⚠️  Skipping question: "${q.text.substring(0, 30)}..." - Correct answer "${q.correctAnswer}" not found in options.`);
                    continue;
                }

                // Check for duplicate
                const existing = await prisma.examQuestion.findFirst({
                    where: {
                        subject: file.subject,
                        questionText: q.text,
                    },
                });

                if (existing) {
                    skippedCount++;
                    continue;
                }

                await prisma.examQuestion.create({
                    data: {
                        subject: file.subject,
                        questionText: q.text,
                        options: q.options,
                        correctAnswer: correctIndex,
                        isActive: true,
                        difficulty: 1, // Default difficulty
                    },
                });
                importedCount++;
            }

            console.log(`✅ ${file.name}: Imported ${importedCount}, Skipped ${skippedCount} (duplicates)`);

        } catch (error) {
            console.error(`❌ Error processing ${file.name}:`, error);
        }
    }

    console.log('\n🏁 Import completed!');
    await prisma.$disconnect();
}

importQuestions()
    .catch((e) => {
        console.error(e);
        prisma.$disconnect();
        process.exit(1);
    });
