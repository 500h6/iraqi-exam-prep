
import { Telegraf } from 'telegraf';
import * as dotenv from 'dotenv';
dotenv.config();

async function resetBot() {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    if (!token) {
        console.error('❌ TELEGRAM_BOT_TOKEN is missing');
        return;
    }

    const bot = new Telegraf(token);

    try {
        console.log('🔄 Deleting Webhook...');
        await bot.telegram.deleteWebhook({ drop_pending_updates: true });
        console.log('✅ Webhook deleted & updates dropped.');

        console.log('🔄 Closing local session...');
        // Just a simple check
        const me = await bot.telegram.getMe();
        console.log(`✅ Bot Valid: @${me.username}`);

    } catch (error) {
        console.error('❌ Error resetting bot:', error);
    }
}

resetBot();
