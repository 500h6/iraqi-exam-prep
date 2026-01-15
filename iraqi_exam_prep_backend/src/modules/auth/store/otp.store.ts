
export const otpStore = new Map<string, { code: string; expires: number }>();

export const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

export const storeOtp = (phone: string, code: string) => {
    const expires = Date.now() + 5 * 60 * 1000; // 5 minutes
    otpStore.set(phone, { code, expires });
};

export const getOtp = (phone: string) => otpStore.get(phone);

export const deleteOtp = (phone: string) => otpStore.delete(phone);
