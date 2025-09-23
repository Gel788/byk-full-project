"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.logout = exports.register = exports.login = void 0;
const User_1 = __importDefault(require("../models/User"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const login = async (req, res) => {
    try {
        const { phone, password, email } = req.body;
        // Логируем входящие данные
        console.log('Login attempt:', { phone, email, hasPassword: !!password });
        // Проверяем что предоставлены необходимые данные
        if (!password || (!phone && !email)) {
            console.log('Validation failed: missing required fields');
            return res.status(400).json({
                success: false,
                message: 'Необходимо указать номер телефона (или email) и пароль'
            });
        }
        // Ищем пользователя по телефону или email
        let user;
        if (phone) {
            user = await User_1.default.findOne({
                $or: [
                    { phone },
                    { phoneNumber: phone }
                ]
            });
        }
        else if (email) {
            user = await User_1.default.findOne({ email });
        }
        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Пользователь не найден'
            });
        }
        // Проверяем пароль
        const isPasswordValid = await bcryptjs_1.default.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Неверный пароль'
            });
        }
        // Проверяем активность пользователя
        if (!user.isActive) {
            return res.status(401).json({
                success: false,
                message: 'Аккаунт заблокирован'
            });
        }
        // Создаем JWT токен
        const token = jsonwebtoken_1.default.sign({
            userId: user._id,
            username: user.username,
            role: user.role
        }, JWT_SECRET, { expiresIn: '24h' });
        // Возвращаем данные пользователя (без пароля) и токен
        const userData = {
            id: user._id,
            username: user.username || user.fullName,
            email: user.email,
            fullName: user.fullName,
            phone: user.phone || user.phoneNumber,
            role: user.role || 'user',
            isActive: user.isActive ?? true
        };
        res.json({
            success: true,
            message: 'Успешная авторизация',
            user: userData,
            token
        });
    }
    catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Ошибка сервера при авторизации'
        });
    }
};
exports.login = login;
const register = async (req, res) => {
    try {
        const { username, email, password, fullName, phone } = req.body;
        // Проверяем обязательные поля
        if (!username || !email || !password || !fullName) {
            return res.status(400).json({
                success: false,
                message: 'Необходимо указать имя пользователя, email, пароль и полное имя'
            });
        }
        // Проверяем уникальность username и email
        const existingUser = await User_1.default.findOne({
            $or: [{ username }, { email }]
        });
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'Пользователь с таким именем или email уже существует'
            });
        }
        // Хешируем пароль
        const saltRounds = 10;
        const hashedPassword = await bcryptjs_1.default.hash(password, saltRounds);
        // Создаем пользователя
        const user = new User_1.default({
            username,
            email,
            password: hashedPassword,
            fullName,
            phone: phone || undefined,
            phoneNumber: phone || undefined, // Для совместимости с мобильным приложением
            role: 'user',
            isActive: true
        });
        const savedUser = await user.save();
        // Создаем JWT токен
        const token = jsonwebtoken_1.default.sign({
            userId: savedUser._id,
            username: savedUser.username,
            role: savedUser.role
        }, JWT_SECRET, { expiresIn: '24h' });
        // Возвращаем данные пользователя (без пароля) и токен
        const userData = {
            id: savedUser._id,
            username: savedUser.username,
            email: savedUser.email,
            fullName: savedUser.fullName,
            phone: savedUser.phone || savedUser.phoneNumber,
            role: savedUser.role,
            isActive: savedUser.isActive
        };
        res.status(201).json({
            success: true,
            message: 'Пользователь успешно зарегистрирован',
            user: userData,
            token
        });
    }
    catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Ошибка сервера при регистрации'
        });
    }
};
exports.register = register;
const logout = async (req, res) => {
    try {
        // В простой реализации просто возвращаем успех
        // В более сложной можно добавить blacklist токенов
        res.json({
            success: true,
            message: 'Успешный выход из системы'
        });
    }
    catch (error) {
        console.error('Logout error:', error);
        res.status(500).json({
            success: false,
            message: 'Ошибка сервера при выходе'
        });
    }
};
exports.logout = logout;
