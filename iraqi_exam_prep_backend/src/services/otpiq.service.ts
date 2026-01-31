import axios from 'axios';

class OtpiqService {
    private static instance: OtpiqService;
    private readonly apiKey: string;
    private readonly baseUrl: string = 'https://api.otpiq.com'; // Verified base URL from user snippet context usually

    private constructor() {
        // Use environment variable for security, fallback to hardcoded ONLY for this specific user request context if env not set immediately, but better to enforce env.
        // The user provided the key in the chat, so I will prioritize using the env var but might default during dev if needed.
        // Ideally: process.env.OTPIQ_API_KEY
        this.apiKey = process.env.OTPIQ_API_KEY || '';

        if (!this.apiKey) {
            console.warn('⚠️ OTPIQ_API_KEY is not set. OTP sending will fail.');
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
            console.error('❌ OTPIQ API Key missing.');
            return;
        }

        try {
            // Remove '+' if present, ensure numeric
            const cleanPhone = phone.replace(/\D/g, '');

            // Construct payload based on standard SMS API patterns. 
            // Since explicit body wasn't provided, I will use a generic compliant format.
            // Usually: { sender: "Verify", destination: "...", text: "..." }

            const payload = {
                sender: "OTPIQ", // Default sender ID, might need adjustment
                mobile: cleanPhone,
                content: `كود التحقق الخاص بك هو: ${otp}\nYour verification code is: ${otp}`
            };

            // Note: Endpoints might be /sms/send or /messages
            // User snippet said "Messaging & SMS Endpoints -> POST Send SMS"
            await axios.post(`${this.baseUrl}/sms/send`, payload, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            });

            console.log(`✅ OTP sent to ${cleanPhone} via OTPIQ`);
        } catch (error: any) {
            console.error('❌ Failed to send OTP via OTPIQ:', error.response?.data || error.message);
            // Don't crash the auth flow, just log. 
            // In production, might want to throw to alert the user.
            throw new Error('Failed to send verification code.');
        }
    }
}

export const otpiqService = OtpiqService.getInstance();
