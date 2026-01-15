
import { normalizePhoneNumber } from './src/utils/phoneUtils';

const numbers = [
    '+964 781 001 1034',
    '00964 781 001 1034',
    '0781 001 1034',
    '781 001 1034',
    '9647810011034',
    '07810011034',
    '+9647810011034'
];

numbers.forEach(n => {
    // Mimic Telegram logic
    const rawArgs = n.replace('+', '');
    const normalized = normalizePhoneNumber(rawArgs);
    console.log(`Input: "${n}" -> Args: "${rawArgs}" -> Norm: "${normalized}"`);
});
