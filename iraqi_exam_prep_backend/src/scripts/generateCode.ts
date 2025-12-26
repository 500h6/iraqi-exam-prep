import "dotenv/config";
import { Subject } from "@prisma/client";
import { prisma } from "../modules/shared/prisma";
import { activationCodeService } from "../modules/admin/services/activationCode.service";
import { logger } from "../config/logger";

/**
 * CLI Script to generate activation codes
 * 
 * Usage:
 *   npx ts-node src/scripts/generateCode.ts [options]
 * 
 * Options:
 *   --subjects ARABIC,ENGLISH,COMPUTER  Subjects to unlock (comma-separated)
 *   --all                               Unlock all subjects
 *   --count 5                           Number of codes to generate (default: 1)
 *   --uses 1                            Max uses per code (default: 1)
 *   --expires 30                        Expires in N days (optional)
 * 
 * Examples:
 *   npx ts-node src/scripts/generateCode.ts --all --count 10
 *   npx ts-node src/scripts/generateCode.ts --subjects ARABIC --uses 5
 */

const parseArgs = () => {
    const args = process.argv.slice(2);
    const options: {
        subjects: Subject[];
        unlockAll: boolean;
        count: number;
        maxUses: number;
        expiresInDays?: number;
    } = {
        subjects: [],
        unlockAll: false,
        count: 1,
        maxUses: 1,
    };

    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        switch (arg) {
            case "--subjects":
                const subjectsStr = args[++i];
                if (subjectsStr) {
                    options.subjects = subjectsStr
                        .split(",")
                        .map((s) => s.toUpperCase().trim() as Subject);
                }
                break;
            case "--all":
                options.unlockAll = true;
                break;
            case "--count":
                options.count = parseInt(args[++i] || "1", 10);
                break;
            case "--uses":
                options.maxUses = parseInt(args[++i] || "1", 10);
                break;
            case "--expires":
                options.expiresInDays = parseInt(args[++i] || "30", 10);
                break;
        }
    }

    return options;
};

const main = async () => {
    const options = parseArgs();

    console.log("\n🔑 Generating Activation Code(s)...\n");
    console.log("Options:", {
        subjects: options.subjects.length > 0 ? options.subjects : "(via unlockAll)",
        unlockAll: options.unlockAll,
        count: options.count,
        maxUses: options.maxUses,
        expiresInDays: options.expiresInDays || "Never",
    });

    let codes;
    if (options.count > 1) {
        codes = await activationCodeService.generateBulkCodes(options.count, options);
    } else {
        const code = await activationCodeService.generateCode(options);
        codes = [code];
    }

    console.log("\n✅ Generated Codes:\n");
    console.log("┌────────────────────────────────────────────────────┐");
    codes.forEach((c) => {
        console.log(`│  📋 ${c.code.padEnd(45)} │`);
    });
    console.log("└────────────────────────────────────────────────────┘");

    console.log(`\n📊 Total: ${codes.length} code(s) generated.`);
    console.log("💡 Copy the code(s) above and share with your customers.\n");
};

main()
    .then(async () => {
        await prisma.$disconnect();
        process.exit(0);
    })
    .catch(async (error) => {
        logger.error(error, "Failed to generate codes");
        await prisma.$disconnect();
        process.exit(1);
    });
