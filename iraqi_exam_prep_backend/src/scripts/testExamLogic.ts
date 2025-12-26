
import { PrismaClient, Subject } from '@prisma/client';
import { examService } from '../modules/exams/services/exam.service';

const prisma = new PrismaClient();

async function main() {
    console.log('🧪 Starting Exam Logic Verification...');

    const email = 'test_logic@example.com';
    const TEST_SUBJECT = 'ENGLISH' as Subject; // Ensure this is a valid enum value

    // 1. Create Test User
    const user = await prisma.user.upsert({
        where: { email },
        update: {},
        create: {
            email,
            name: 'Logic Tester',
            passwordHash: 'hashed_dummy',
        }
    });
    console.log(`👤 User ready: ${user.id}`);

    // 2. Clean up previous test data for this subject
    // Note: In a real env be careful, but this is a script.
    // Delete results first due to FK constraint
    await prisma.examResult.deleteMany({
        where: { userId: user.id, subject: TEST_SUBJECT }
    });

    await prisma.examAttempt.deleteMany({
        where: { userId: user.id, subject: TEST_SUBJECT }
    });
    // We won't delete all questions to avoid breaking other things, 
    // but we will create specific tagged questions if possible, 
    // or just rely on IDs we create now.

    // Let's create 30 fresh questions for this test to be sure.
    const createdQuestionIds: string[] = [];

    console.log('📝 Seeding questions...');
    for (let i = 0; i < 30; i++) {
        const q = await prisma.examQuestion.create({
            data: {
                subject: TEST_SUBJECT,
                questionText: `Test Question ${i} ${Date.now()}`,
                options: ['A', 'B', 'C', 'D'],
                correctAnswer: 0, // Always A is correct for simplicity
                difficulty: 1,
            }
        });
        createdQuestionIds.push(q.id);
    }

    const wrongIds = createdQuestionIds.slice(0, 10);
    const correctIds = createdQuestionIds.slice(10, 20);
    const newIds = createdQuestionIds.slice(20, 30);

    // 3. Simulate History
    console.log('📜 Simulating exam history...');

    // Attempt 1: Get the "wrong" questions wrong
    const wrongAnswers: Record<string, number> = {};
    wrongIds.forEach(id => { wrongAnswers[id] = 1; }); // Opt 1 (B) is wrong (0 is correct)
    await examService.submitExam(user.id, TEST_SUBJECT, wrongAnswers);

    // Attempt 2: Get the "correct" questions correct
    const correctAnswers: Record<string, number> = {};
    correctIds.forEach(id => { correctAnswers[id] = 0; }); // Opt 0 (A) is correct
    await examService.submitExam(user.id, TEST_SUBJECT, correctAnswers);

    // 4. Test Selection Algorithm
    console.log('🧠 Testing selection logic...');
    const selectedQuestions = await examService.getQuestions(user.id, TEST_SUBJECT);

    console.log(`📊 Selected ${selectedQuestions.length} questions.`);

    let countWrong = 0;
    let countCorrect = 0;
    let countNew = 0;
    let countOther = 0;

    selectedQuestions.forEach(q => {
        if (wrongIds.includes(q.id)) countWrong++;
        else if (correctIds.includes(q.id)) countCorrect++;
        else if (newIds.includes(q.id)) countNew++;
        else countOther++;
    });

    console.log(`
    Results Distribution:
    - Previous Wrong (High Priority): ${countWrong} / 10 expected
    - New Questions (Medium Priority): ${countNew} / 10 expected
    - Previous Correct (Low Priority): ${countCorrect} / 5-10 expected (fillers)
    - Other (Existing DB questions): ${countOther}
    `);

    // Validation
    const passed =
        countWrong === 10 && // Should prioritize all wrong ones
        countNew === 10 &&   // Should prioritize all new ones
        selectedQuestions.length === 25; // Should be capped at 25

    if (passed) {
        console.log('✅ TEST PASSED: Logic works as expected.');
    } else {
        console.log('❌ TEST FAILED: Distribution mismatch.');
    }

    // Cleanup (Optional, maybe keep for manual inspection)
    // await prisma.examQuestion.deleteMany({ where: { id: { in: createdQuestionIds } } });
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
