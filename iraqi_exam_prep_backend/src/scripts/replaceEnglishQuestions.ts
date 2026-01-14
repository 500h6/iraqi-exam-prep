import { PrismaClient, Subject } from '@prisma/client';
import fs from 'fs';
import path from 'path';

const prisma = new PrismaClient();

// Absolute path to the source file provided by user
const SOURCE_FILE = 'C:\\Users\\TechnoMaster\\Desktop\\newProjects\\apps\\English_Question.json';

interface SourceQuestion {
    questionText: string;
    options: string[];
    correctAnswer: string;
    category?: string;
    explanation?: string;
    difficulty?: number;
}

async function start() {
    console.log('🚀 Starting English questions replacement...');

    // 1. Delete existing English questions
    console.log('🗑️  Deleting all existing English questions...');
    const deleteResult = await prisma.examQuestion.deleteMany({
        where: { subject: Subject.ENGLISH }
    });
    console.log(`✅ Deleted ${deleteResult.count} existing questions.`);

    // 2. Read Source File
    if (!fs.existsSync(SOURCE_FILE)) {
        console.error(`❌ Source file not found: ${SOURCE_FILE}`);
        process.exit(1);
    }

    console.log(`📂 Reading source file...`);
    const rawData = fs.readFileSync(SOURCE_FILE, 'utf-8');
    const questions: SourceQuestion[] = JSON.parse(rawData);
    console.log(`📊 Found ${questions.length} questions in source file.`);

    // 3. Deduplicate and Prepare
    const uniqueQuestions = new Map<string, any>();
    let duplicatesInFile = 0;
    let skippedNoAnswer = 0;

    for (const q of questions) {
        // Normalize text for duplicate detection
        const key = q.questionText.trim().toLowerCase();

        if (uniqueQuestions.has(key)) {
            duplicatesInFile++;
            continue;
        }

        // Find Correct Index
        // The JSON has prefixes like "a. ", "b. " and hidden chars.
        // We find the index based on the raw string match first.
        let correctIndex = q.options.indexOf(q.correctAnswer);

        if (correctIndex === -1) {
            // Fallback: try to match by trimming
            correctIndex = q.options.findIndex(opt => opt.trim() === q.correctAnswer.trim());
        }

        if (correctIndex === -1) {
            // Fallback: try to match checking if option contains text (ignoring prefix)
            // This is risky, let's log it.
            // console.warn(`⚠️  Answer not found for: ${q.questionText.substring(0, 20)}...`);
            skippedNoAnswer++;
            continue;
        }

        // Clean Options (Remove "a. ", "b. ", "c. ", "d. " prefixes and special chars)
        // Regex to remove "a. " or "a)" at start, and unicode LTR/RTL marks
        const cleanOption = (opt: string) => {
            return opt
                .replace(/^[\u200B-\u200F\u202A-\u202E]*[a-dA-D][\.\)]\s*/, '') // Remove "a. "
                .trim();
        };

        const cleanOptions = q.options.map(cleanOption);

        uniqueQuestions.set(key, {
            subject: Subject.ENGLISH,
            questionText: q.questionText.trim(),
            options: cleanOptions,
            correctAnswer: correctIndex,
            category: q.category?.toLowerCase() ?? 'general',
            explanation: q.explanation,
            difficulty: q.difficulty ?? 1,
            isActive: true,
        });
    }

    console.log(`✨ Prepare to insert ${uniqueQuestions.size} unique questions.`);
    console.log(`ℹ️  Skipped ${duplicatesInFile} duplicates within file.`);
    console.log(`ℹ️  Skipped ${skippedNoAnswer} questions with missing answer.`);

    // 4. Insert in Batches
    const BATCH_SIZE = 50;
    const allData = Array.from(uniqueQuestions.values());
    let insertedCount = 0;

    for (let i = 0; i < allData.length; i += BATCH_SIZE) {
        const batch = allData.slice(i, i + BATCH_SIZE);
        await prisma.examQuestion.createMany({
            data: batch,
        });
        insertedCount += batch.length;
        process.stdout.write(`\r⏳ Inserted ${insertedCount}/${allData.length}...`);
    }

    console.log(`\n✅ Successfully replaced English questions!`);
}

start()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
