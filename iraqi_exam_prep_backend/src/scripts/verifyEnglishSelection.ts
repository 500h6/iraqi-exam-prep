import { examService } from '../modules/exams/services/exam.service';
import { prisma } from '../modules/shared/prisma';

async function verifyEnglishSelection() {
    console.log('🧪 Starting English selection verification...');

    // 1. Create a dummy user if not exists
    const testEmail = 'test_verify@example.com';
    let user = await prisma.user.findUnique({ where: { email: testEmail } });
    if (!user) {
        user = await prisma.user.create({
            data: {
                email: testEmail,
                name: 'Test Verify',
                passwordHash: 'dummy',
            }
        });
    }

    try {
        console.log(`\n📋 Requesting 25 English questions for user ${user.id}...`);
        const questions = await examService.getQuestions(user.id, 'ENGLISH');

        console.log(`✅ Received ${questions.length} questions.`);

        const stats: Record<string, number> = {};
        questions.forEach(q => {
            const cat = (q as any).category || 'no-category';
            stats[cat] = (stats[cat] || 0) + 1;
        });

        console.log('\n📊 Distribution Stats:');
        console.log(`- Grammar: ${stats['grammar'] || 0} (Target: 11)`);
        console.log(`- Functions: ${stats['functions'] || 0} (Target: 8)`);
        console.log(`- Reading: ${stats['reading'] || 0} (Target: 6)`);

        const total = (stats['grammar'] || 0) + (stats['functions'] || 0) + (stats['reading'] || 0);
        if (total === 25 && stats['grammar'] === 11 && stats['functions'] === 8 && stats['reading'] === 6) {
            console.log('\n✨ Verification PASSED! Distribution is perfect.');
        } else {
            console.warn('\n⚠️ Verification failed or partial match. Check logs.');
        }

    } catch (error) {
        console.error('❌ Error during verification:', error);
    }

    await prisma.$disconnect();
}

verifyEnglishSelection();
