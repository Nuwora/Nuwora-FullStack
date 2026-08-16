import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { signAccessToken } from '../../lib/jwt';
import { validateBody } from '../../middleware/validate';
import {
  anonymousAuthSchema,
  loginSchema,
  registerSchema,
  LoginInput,
  RegisterInput,
} from './schema';
import { findOrCreateUserByDeviceId, loginUser, registerUser } from './service';

export const authRouter = Router();

authRouter.post('/auth/anonymous', validateBody(anonymousAuthSchema), async (req, res, next) => {
  try {
    const { deviceID } = req.body as { deviceID: string };
    const { userId, isNewUser } = await findOrCreateUserByDeviceId(prisma, deviceID);
    const accessToken = signAccessToken(userId);
    res.status(200).json({
      accessToken,
      user: { id: userId, isNewUser },
    });
  } catch (error) {
    next(error);
  }
});

authRouter.post('/auth/register', validateBody(registerSchema), async (req, res, next) => {
  try {
    const { email, password } = req.body as RegisterInput;
    const { userId, isNewUser } = await registerUser(prisma, email, password);
    const accessToken = signAccessToken(userId);
    res.status(200).json({
      accessToken,
      user: { id: userId, isNewUser },
    });
  } catch (error) {
    next(error);
  }
});

authRouter.post('/auth/login', validateBody(loginSchema), async (req, res, next) => {
  try {
    const { email, password } = req.body as LoginInput;
    const { userId, isNewUser } = await loginUser(prisma, email, password);
    const accessToken = signAccessToken(userId);
    res.status(200).json({
      accessToken,
      user: { id: userId, isNewUser },
    });
  } catch (error) {
    next(error);
  }
});
