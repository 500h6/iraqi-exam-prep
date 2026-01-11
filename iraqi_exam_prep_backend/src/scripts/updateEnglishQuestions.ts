import { PrismaClient, Subject } from '@prisma/client';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();

interface EnglishQuestionJson {
    questionText: string;
    options: string[];
    correctAnswer: string;
    category: string;
    explanation?: string;
    difficulty?: number;
    isActive?: boolean;
}

async function updateEnglishQuestions() {
    console.log('🚀 Starting English questions update...');

    const filePath = path.join(process.cwd(), '..', 'English_Question.json');

    if (!fs.existsSync(filePath)) {
        console.error(`❌ File not found: ${filePath}`);
        process.exit(1);
    }

    try {
        const rawData = fs.readFileSync(filePath, 'utf-8');
        const questions: EnglishQuestionJson[] = JSON.parse(rawData);

        console.log(`\n🗑️ Clearing old English questions...`);
        const deleteResult = await prisma.examQuestion.deleteMany({
            where: {
                subject: Subject.ENGLISH
            }
        });
        console.log(`✅ Deleted ${deleteResult.count} old questions.`);

        console.log(`\n📂 Processing English_Question.json...`);

        let importedCount = 0;
        let skippedCount = 0;

        for (const q of questions) {
            // Find index of correct answer
            // The JSON has string answers like "‏b. were walking"
            // Let's find which option matches this.
            const correctIndex = q.options.findIndex(opt => opt.trim() === q.correctAnswer.trim());

            if (correctIndex === -1) {
                console.warn(`⚠️  Skipping question: "${q.questionText.substring(0, 30)}..." - Correct answer "${q.correctAnswer}" not found in options.`);
                skippedCount++;
                continue;
            }

            await prisma.examQuestion.create({
                data: {
                    subject: Subject.ENGLISH,
                    questionText: q.questionText,
                    options: q.options,
                    correctAnswer: correctIndex,
                    category: q.category.toLowerCase(),
                    explanation: q.explanation || null,
                    difficulty: q.difficulty || 1,
                    isActive: q.isActive !== undefined ? q.isActive : true,
                },
            });
            importedCount++;
        }

        console.log(`\n✅ Imported ${importedCount}, Skipped ${skippedCount}`);

    } catch (error) {
        console.error(`❌ Error processing English questions:`, error);
    }

    console.log('\n🏁 Update completed!');
    await prisma.$disconnect();
}

updateEnglishQuestions()
    .catch((e) => {
        console.error(e);
        prisma.$disconnect();
        process.exit(1);
    });
