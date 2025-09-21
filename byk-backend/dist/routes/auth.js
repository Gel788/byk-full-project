"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const authController_1 = require("../controllers/authController");
const router = express_1.default.Router();
// POST /api/auth/login - авторизация
router.post('/login', authController_1.login);
// POST /api/auth/register - регистрация
router.post('/register', authController_1.register);
// POST /api/auth/logout - выход
router.post('/logout', authController_1.logout);
exports.default = router;
