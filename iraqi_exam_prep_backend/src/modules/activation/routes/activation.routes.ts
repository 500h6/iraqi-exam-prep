import { Router } from "express";
import {
  activationStatusHandler,
  activationValidateHandler,
} from "../controllers/activation.controller";
import { authenticate } from "../../../middlewares/authMiddleware";
import { validateResource } from "../../../middlewares/validateResource";
import { activationCodeSchema } from "../dtos/activation.schema";

export const activationRouter = Router();

activationRouter.get(
  "/status",
  authenticate(),
  activationStatusHandler,
);

activationRouter.post(
  "/validate",
  authenticate(),
  validateResource(activationCodeSchema),
  activationValidateHandler,
);
