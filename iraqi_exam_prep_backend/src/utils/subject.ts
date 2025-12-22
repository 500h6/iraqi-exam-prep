import { Subject } from "@prisma/client";

export const normalizeSubject = (subjectParam: string): Subject => {
  const normalized = subjectParam.trim().toUpperCase();
  if (!(normalized in Subject)) {
    throw new Error(`Unsupported subject: ${subjectParam}`);
  }
  return Subject[normalized as keyof typeof Subject];
};
