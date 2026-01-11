
import { PrismaClient, Subject } from '@prisma/client';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();

interface QuestionJson {
    questionText: string;
    options: string[];
    correctAnswer: string;
    explanation?: string;
    difficulty?: number;
    isActive?: boolean;
}

const FILE_NAME = 'Computer_Question.json';

async function updateComputerQuestions() {
    console.log('🚀 Starting Computer Science questions update...');

    const filePath = path.join(process.cwd(), '..', FILE_NAME);

    if (!fs.existsSync(filePath)) {
        console.error(`❌ File not found: ${filePath}`);
        process.exit(1);
    }

    try {
        const rawData = fs.readFileSync(filePath, 'utf-8');
        const questions: QuestionJson[] = JSON.parse(rawData);

        console.log(`📂 Loaded ${questions.length} questions from ${FILE_NAME}`);

        // 1. Delete existing COMPUTER questions
        console.log('🗑️ Deleting existing COMPUTER questions...');
        const deleted = await prisma.examQuestion.deleteMany({
            where: {
                subject: Subject.COMPUTER
            }
        });
        console.log(`✅ Deleted ${deleted.count} old questions.`);

        // 2. Prepare new questions
        console.log('📝 Preparing new questions...');
        const newQuestionsData = questions.map((q, index) => {
            const correctIndex = q.options.indexOf(q.correctAnswer);

            if (correctIndex === -1) {
                console.warn(`⚠️ Warning: Question at index ${index} has an invalid correct answer: "${q.correctAnswer}"`);
            }

            return {
                subject: Subject.COMPUTER,
                questionText: q.questionText,
                options: q.options,
                correctAnswer: correctIndex === -1 ? 0 : correctIndex, // Fallback to 0 if not found
                explanation: q.explanation || '',
                difficulty: q.difficulty || 1,
                isActive: q.isActive !== undefined ? q.isActive : true,
            };
        });

        // 3. Insert new questions
        console.log('📤 Inserting new questions...');
        const created = await prisma.examQuestion.createMany({
            data: newQuestionsData
        });

        console.log(`✅ Successfully imported ${created.count} new questions!`);

    } catch (error) {
        console.error('❌ Error updating questions:', error);
    } finally {
        await prisma.$disconnect();
    }

    console.log('\n🏁 Process completed!');
}

updateComputerQuestions()
    .catch((e) => {
        console.error(e);
        prisma.$disconnect();
        process.exit(1);
    });
