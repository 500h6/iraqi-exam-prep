/**
 * Phone Number Normalization Utility
 * Handles all Iraqi phone number formats and normalizes to: 9647XXXXXXXX
 * 
 * Supported formats:
 * - +9647810011034 -> 9647810011034
 * - 009647810011034 -> 9647810011034
 * - 9647810011034 -> 9647810011034
 * - 07810011034 -> 9647810011034
 * - 7810011034 -> 9647810011034
 */

const IRAQ_COUNTRY_CODE = '964';

export function normalizePhoneNumber(phone: string): string {
    // 1. Convert Arabic/Persian digits to English digits
    const arabicDigits = /[٠١٢٣٤٥٦٧٨٩]/g;
    const persianDigits = /[۰۱۲۳۴۵۶۷۸۹]/g;

    let normalized = phone
        .replace(arabicDigits, (d) => (d.charCodeAt(0) - 1632).toString())
        .replace(persianDigits, (d) => (d.charCodeAt(0) - 1776).toString());

    // 2. Remove all non-digit characters
    normalized = normalized.replace(/\D/g, '');

    // 3. Handle different formats
    if (normalized.startsWith('00964')) {
        normalized = normalized.substring(2);
    } else if (normalized.startsWith('964')) {
        // Already correct
    } else if (normalized.startsWith('07')) {
        normalized = IRAQ_COUNTRY_CODE + normalized.substring(1);
    } else if (normalized.startsWith('7') && normalized.length === 10) {
        normalized = IRAQ_COUNTRY_CODE + normalized;
    }

    return normalized;
}

/**
 * Generates all possible phone number variants for database lookup
 * Useful when we're not sure which format is stored
 */
export function getPhoneVariants(phone: string): string[] {
    const normalized = normalizePhoneNumber(phone);

    // Extract the local part (without country code)
    let localNumber = normalized;
    if (normalized.startsWith('964')) {
        localNumber = normalized.substring(3);
    }

    return [
        normalized,                    // 9647810011034
        `+${normalized}`,              // +9647810011034
        `00${normalized}`,             // 009647810011034
        `0${localNumber}`,             // 07810011034
        localNumber,                   // 7810011034
    ];
}
