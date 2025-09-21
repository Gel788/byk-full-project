import express from 'express';
import { login, register, logout } from '../controllers/authController';

const router = express.Router();

// POST /api/auth/login - авторизация
router.post('/login', login);

// POST /api/auth/register - регистрация
router.post('/register', register);

// POST /api/auth/logout - выход
router.post('/logout', logout);

export default router;
