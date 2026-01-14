import { Telegraf, Context } from 'telegraf';
import { prisma } from '../../shared/prisma';

export class TelegramService {
    private bot: Telegraf | null = null;
    private isRunning = false;

    constructor() {
        const token = process.env.TELEGRAM_BOT_TOKEN;
        if (token) {
            this.bot = new Telegraf(token);
            this.initializeBot();
        } else {
            console.warn('⚠️ TELEGRAM_BOT_TOKEN not found. Telegram automation disabled.');
        }
    }

    private initializeBot() {
        if (!this.bot) return;

        // Handle Start and Contact
        this.bot.start((ctx) => {
            ctx.reply(
                'Welcome to Iraqi Exam Prep! 🇮🇶\nPlease share your contact number to link your account.',
                {
                    reply_markup: {
                        keyboard: [
                            [
                                {
                                    text: '📱 Share Contact',
                                    request_contact: true,
                                },
                            ],
                        ],
                        one_time_keyboard: true,
                        resize_keyboard: true,
                    },
                }
            );
        });

        this.bot.on('contact', async (ctx) => {
            const contact = ctx.message.contact;
            if (!contact) return;

            const phone = contact.phone_number.replace('+', '');
            const chatId = ctx.chat.id.toString();
            const firstName = contact.first_name;

            try {
                // Upsert User: Link ChatID to Phone
                // If user exists with this phone, update ChatID
                // If user doesn't exist, create partial user
                const user = await prisma.user.upsert({
                    where: { phone },
                    update: { telegramChatId: chatId },
                    create: {
                        phone,
                        telegramChatId: chatId,
                        name: firstName || 'New Student', // Temporary name
                        role: 'STUDENT',
                    },
                });

                await ctx.reply(`✅ Account Linked Successfully!\nPhone: ${phone}\n\nYou can now receive login codes here.`);
                console.log(`🔗 Linked Phone ${phone} to ChatID ${chatId}`);
            } catch (error) {
                console.error('Error linking telegram:', error);
                ctx.reply('❌ Failed to link account. Please try again.');
            }
        });

        // Launch Bot
        this.bot.launch().then(() => {
            this.isRunning = true;
            console.log('🤖 Telegram Bot Started!');
        }).catch(err => {
            console.error('❌ Telegram Bot Failed to Start:', err);
        });

        // Graceful Stop
        process.once('SIGINT', () => this.bot?.stop('SIGINT'));
        process.once('SIGTERM', () => this.bot?.stop('SIGTERM'));
    }

    async sendOtp(phone: string, code: string): Promise<boolean> {
        if (!this.bot) return false;

        // 1. Find Chat ID by Phone
        const user = await prisma.user.findUnique({
            where: { phone },
            select: { telegramChatId: true },
        });

        if (!user || !user.telegramChatId) {
            console.log(`⚠️ No Telegram ChatID found for phone ${phone}`);
            return false; // User needs to link account
        }

        // 2. Send Message
        try {
            await this.bot.telegram.sendMessage(
                user.telegramChatId,
                `🔐 *${code}* is your Login Code.\n\nDo not share it with anyone.`,
                { parse_mode: 'Markdown' }
            );
            return true;
        } catch (error) {
            console.error(`❌ Failed to send OTP to ${phone}:`, error);
            return false;
        }
    }
}

export const telegramService = new TelegramService();
