
export const otpStore = new Map<string, { code: string; expires: number }>();

export const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

export const storeOtp = (phone: string, code: string) => {
    const expires = Date.now() + 5 * 60 * 1000; // 5 minutes
    console.log(`💾 STORE OTP: Phone=${phone}, Code=${code}, Expires=${expires}`);
    otpStore.set(phone, { code, expires });
    console.log(`💾 Current Store Size: ${otpStore.size}`);
};

export const getOtp = (phone: string) => {
    const data = otpStore.get(phone);
    console.log(`🔍 GET OTP: Phone=${phone}, Found=${!!data}, DataCode=${data?.code}`);
    return data;
};

export const deleteOtp = (phone: string) => otpStore.delete(phone);
