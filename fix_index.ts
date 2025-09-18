import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';

// Импорты роутов
import usersRouter from './routes/users';
import restaurantsRouter from './routes/restaurants';
import dishesRouter from './routes/dishes';
import newsRouter from './routes/news';
import adminRouter from './admin/routes/adminRoutes';

// Загружаем переменные окружения
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(morgan('combined'));
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// API роуты
app.use('/api/users', usersRouter);
app.use('/api/restaurants', restaurantsRouter);
app.use('/api/dishes', dishesRouter);
app.use('/api/news', newsRouter);
app.use('/api/admin', adminRouter);

// Базовые роуты
app.get('/', (req, res) => {
  res.json({
    message: 'БЫК Holding API',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

// Запуск сервера
app.listen(PORT, () => {
  console.log(`🚀 Сервер запущен на порту ${PORT}`);
  console.log(`📱 API доступно по адресу: http://45.12.75.59:${PORT}`);
  console.log(`🏥 Health check: http://45.12.75.59:${PORT}/health`);
});

export default app;
