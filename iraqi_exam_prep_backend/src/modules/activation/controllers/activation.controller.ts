import { Response } from "express";
import { activationService } from "../services/activation.service";
import { AuthenticatedRequest } from "../../../middlewares/authMiddleware";
import { sendSuccess } from "../../../utils/response";

export const activationStatusHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const status = await activationService.checkStatus(req.user!.id);
  return sendSuccess(res, { data: status });
};

export const activationValidateHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const updated = await activationService.validateCode(
    req.user!.id,
    req.body.code,
  );
  return sendSuccess(
    res,
    {
      data: {
        isPremium: updated.isPremium,
        unlockedSubjects: updated.unlockedSubjects,
        premiumUntil: updated.premiumUntil,
      },
      message: "Activation successful",
    },
  );
};
