import axios from 'axios';
import { AppError } from '../utils/appError';
import { logger } from '../config/logger';

class OtpiqService {
    private static instance: OtpiqService;
    private readonly apiKey: string;
    private readonly baseUrl: string = 'https://api.otpiq.com/api';

    private constructor() {
        this.apiKey = process.env.OTPIQ_API_KEY || '';

        if (!this.apiKey) {
            logger.warn('⚠️ OTPIQ_API_KEY is not set. OTP sending will fail.');
        }
    }

    public static getInstance(): OtpiqService {
        if (!OtpiqService.instance) {
            OtpiqService.instance = new OtpiqService();
        }
        return OtpiqService.instance;
    }

    /**
     * Sends an OTP via WhatsApp/SMS using OTPIQ
     * @param phone Phone number in international format (e.g., 96478...)
     * @param otp The One-Time Password to send
     */
    public async sendOtp(phone: string, otp: string): Promise<void> {
        if (!this.apiKey) {
            logger.error('❌ OTPIQ API Key missing.');
            throw new AppError('Verfication service not configured', 500, 'SMS_SERVICE_CONFIG_ERROR');
        }

        try {
            // Remove '+' if present, ensure numeric
            const cleanPhone = phone.replace(/\D/g, '');

            // Construct payload based on standard SMS API patterns. 
            // Since explicit body wasn't provided, I will use a generic compliant format.
            // Usually: { sender: "Verify", destination: "...", text: "..." }

            const payload = {
                phoneNumber: cleanPhone,
                smsType: "verification",
                verificationCode: otp,
                provider: "auto"
            };

            await axios.post(`${this.baseUrl}/sms`, payload, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            });

            logger.info({ phone: cleanPhone }, `✅ OTP sent via OTPIQ`);
        } catch (error: any) {
            const errorData = error.response?.data;
            const status = error.response?.status || 500;

            logger.error({
                err: error.message,
                data: errorData,
                status
            }, '❌ Failed to send OTP via OTPIQ');

            // Provide a user-friendly message but keep the technical details in the logs
            throw new AppError(
                'فشل إرسال كود التحقق. يرجى المحاولة لاحقاً.',
                status >= 500 ? 503 : 400,
                'SMS_SEND_FAILED'
            );
        }
    }
}

export const otpiqService = OtpiqService.getInstance();
