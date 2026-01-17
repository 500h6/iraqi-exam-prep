import { Telegraf, Context } from 'telegraf';
import { prisma } from '../shared/prisma';
import { normalizePhoneNumber, getPhoneVariants } from '../../utils/phoneUtils';
import { generateOtp, storeOtp } from '../auth/store/otp.store';

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
                'أهلاً بك في تطبيق "الامتحان الوطني"! 🇮🇶\nيرجى مشاركة رقم هاتفك لربط حسابك.',
                {
                    reply_markup: {
                        keyboard: [
                            [
                                {
                                    text: '📱 مشاركة الرقم',
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

            // Normalize phone number to standard format
            const rawPhone = contact.phone_number.replace('+', '');
            const phone = normalizePhoneNumber(rawPhone);
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
                        name: firstName || 'طالب جديد', // Temporary name
                        role: 'STUDENT',
                    },
                });

                // Generate and Store OTP instantly
                const code = generateOtp();
                storeOtp(phone, code); // store with normalized phone

                await ctx.reply(`✅ تم ربط الحساب بنجاح!\n\n🔐 رمز الدخول الخاص بك هو: \`${code}\`\n\nارجع إلى التطبيق وأدخل الرمز لإتمام الدخول.`, { parse_mode: 'Markdown' });
                console.log(`🔗 Linked Phone ${phone} to ChatID ${chatId} & Sent OTP`);
            } catch (error) {
                console.error('Error linking telegram:', error);
                ctx.reply('❌ فشل ربط الحساب. يرجى المحاولة مرة أخرى.');
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

        // Normalize and get all possible phone formats
        const phoneVariants = getPhoneVariants(phone);

        // 1. Find Chat ID by any phone variant
        const user = await prisma.user.findFirst({
            where: { phone: { in: phoneVariants } },
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
                `🔐 \`${code}\` هو رمز دخولك\n\nارجع الى التطبيق وقم بتسجيل الدخول باستخدام الرمز.`,
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
