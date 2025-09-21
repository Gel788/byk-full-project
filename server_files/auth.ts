import express, { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import User, { IUser } from './User';

const router = express.Router();

// Секретный ключ для JWT (в продакшене должен быть в переменных окружения)
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-here';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'your-refresh-secret-key-here';
const JWT_EXPIRES_IN = '24h';
const JWT_REFRESH_EXPIRES_IN = '7d';

// Middleware для проверки JWT токена
export const authenticateToken = async (req: Request, res: Response, next: any) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ 
      success: false, 
      message: 'Токен доступа не предоставлен' 
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Пользователь не найден' 
      });
    }

    (req as any).user = user;
    next();
  } catch (error) {
    return res.status(403).json({ 
      success: false, 
      message: 'Недействительный токен' 
    });
  }
};

// Генерация токенов
const generateTokens = (user: IUser) => {
  const accessToken = jwt.sign(
    { userId: user._id, phoneNumber: user.phoneNumber },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );

  const refreshToken = jwt.sign(
    { userId: user._id },
    JWT_REFRESH_SECRET,
    { expiresIn: JWT_REFRESH_EXPIRES_IN }
  );

  return { accessToken, refreshToken };
};

// Регистрация пользователя
router.post('/register', async (req: Request, res: Response) => {
  try {
    const { phoneNumber, password, fullName, email } = req.body;

    // Проверка обязательных полей
    if (!phoneNumber || !password || !fullName) {
      return res.status(400).json({
        success: false,
        message: 'Необходимо указать номер телефона, пароль и имя'
      });
    }

    // Проверка существования пользователя
    const existingUser = await User.findOne({ phoneNumber });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Пользователь с таким номером телефона уже существует'
      });
    }

    // Создание нового пользователя
    const user = new User({
      phoneNumber,
      password,
      fullName,
      email: email || undefined
    });

    await user.save();

    // Генерация токенов
    const { accessToken, refreshToken } = generateTokens(user);

    // Сохранение refresh токена
    user.refreshTokens.push(refreshToken);
    await user.save();

    res.status(201).json({
      success: true,
      message: 'Пользователь успешно зарегистрирован',
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        email: user.email,
        avatar: user.avatar,
        isVerified: user.isVerified,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        postsCount: user.postsCount,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      },
      token: accessToken,
      refreshToken: refreshToken
    });

  } catch (error: any) {
    console.error('Ошибка регистрации:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при регистрации'
    });
  }
});

// Вход пользователя
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { phoneNumber, password } = req.body;

    // Проверка обязательных полей
    if (!phoneNumber || !password) {
      return res.status(400).json({
        success: false,
        message: 'Необходимо указать номер телефона и пароль'
      });
    }

    // Поиск пользователя
    const user = await User.findOne({ phoneNumber });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Неверный номер телефона или пароль'
      });
    }

    // Проверка пароля
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Неверный номер телефона или пароль'
      });
    }

    // Генерация токенов
    const { accessToken, refreshToken } = generateTokens(user);

    // Сохранение refresh токена
    user.refreshTokens.push(refreshToken);
    await user.save();

    res.json({
      success: true,
      message: 'Успешный вход в систему',
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        email: user.email,
        avatar: user.avatar,
        isVerified: user.isVerified,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        postsCount: user.postsCount,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      },
      token: accessToken,
      refreshToken: refreshToken
    });

  } catch (error: any) {
    console.error('Ошибка входа:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при входе'
    });
  }
});

// Выход пользователя
router.post('/logout', authenticateToken, async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;
    const { token } = req.body;

    // Удаление всех refresh токенов пользователя
    user.refreshTokens = [];
    await user.save();

    res.json({
      success: true,
      message: 'Успешный выход из системы'
    });

  } catch (error: any) {
    console.error('Ошибка выхода:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при выходе'
    });
  }
});

// Обновление токена
router.post('/refresh', async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        message: 'Refresh токен не предоставлен'
      });
    }

    // Проверка refresh токена
    const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET) as any;
    const user = await User.findById(decoded.userId);

    if (!user || !user.refreshTokens.includes(refreshToken)) {
      return res.status(403).json({
        success: false,
        message: 'Недействительный refresh токен'
      });
    }

    // Генерация новых токенов
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);

    // Обновление refresh токенов
    user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
    user.refreshTokens.push(newRefreshToken);
    await user.save();

    res.json({
      success: true,
      message: 'Токен успешно обновлен',
      token: accessToken,
      refreshToken: newRefreshToken
    });

  } catch (error: any) {
    console.error('Ошибка обновления токена:', error);
    res.status(403).json({
      success: false,
      message: 'Недействительный refresh токен'
    });
  }
});

// Получение профиля пользователя
router.get('/profile', authenticateToken, async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;

    res.json({
      id: user._id,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
      email: user.email,
      avatar: user.avatar,
      isVerified: user.isVerified,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
      postsCount: user.postsCount,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt
    });

  } catch (error: any) {
    console.error('Ошибка получения профиля:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при получении профиля'
    });
  }
});

// Обновление профиля пользователя
router.put('/profile', authenticateToken, async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;
    const { fullName, email, avatar } = req.body;

    // Обновление полей
    if (fullName) user.fullName = fullName;
    if (email !== undefined) user.email = email;
    if (avatar !== undefined) user.avatar = avatar;

    await user.save();

    res.json({
      success: true,
      message: 'Профиль успешно обновлен',
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        email: user.email,
        avatar: user.avatar,
        isVerified: user.isVerified,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        postsCount: user.postsCount,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    });

  } catch (error: any) {
    console.error('Ошибка обновления профиля:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера при обновлении профиля'
    });
  }
});

export default router;
