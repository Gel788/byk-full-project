# BYK Web Application

Веб-приложение для ресторанного бизнеса с полной интеграцией API.

## 🚀 Быстрый старт

### Локальная разработка

```bash
# Установка зависимостей
npm install

# Запуск в режиме разработки
npm run dev

# Открыть http://localhost:3000
```

### Развертывание

#### Netlify (рекомендуется)

1. Подключите репозиторий к Netlify
2. Настройки сборки:
   - Build command: `npm run build`
   - Publish directory: `out`
3. Переменные окружения (если нужны):
   - `NODE_ENV=production`

#### Vercel

```bash
# Установка Vercel CLI
npm i -g vercel

# Развертывание
vercel
```

## 📱 Функциональность

- ✅ **Аутентификация** - регистрация, вход, восстановление пароля
- ✅ **Рестораны** - просмотр, фильтрация, детали
- ✅ **Меню** - блюда, категории, цены
- ✅ **Профиль** - управление данными пользователя
- ✅ **Адаптивный дизайн** - работает на всех устройствах

## 🔧 Технологии

- **Next.js 14** - React фреймворк
- **TypeScript** - типизация
- **Tailwind CSS** - стилизация
- **Framer Motion** - анимации
- **API Integration** - подключение к backend

## 📁 Структура проекта

```
web/
├── app/                    # Страницы приложения
│   ├── login/             # Страница входа
│   ├── register/          # Страница регистрации
│   ├── restaurants/       # Список ресторанов
│   ├── profile/           # Профиль пользователя
│   └── ...
├── components/            # React компоненты
├── lib/                   # Утилиты и API
│   ├── api.ts            # API клиент
│   ├── adapters.ts       # Адаптеры данных
│   └── hooks/            # Кастомные хуки
├── types/                 # TypeScript типы
└── contexts/             # React контексты
```

## 🌐 API Интеграция

Приложение интегрировано с backend API:
- **Рестораны:** `/api/restaurants`
- **Блюда:** `/api/dishes`
- **Аутентификация:** `/api/auth`
- **Бренды:** `/api/brands`
- **Города:** `/api/cities`

## 📦 Сборка

```bash
# Статическая сборка
npm run build

# Результат в папке `out/`
```

## 🔗 Ссылки

- **GitHub:** https://github.com/Gel788/byk-full-project
- **Backend API:** https://bulladmin.ru/api
- **Админ панель:** https://bulladmin.ru/admin

## 📝 Лицензия

Private project