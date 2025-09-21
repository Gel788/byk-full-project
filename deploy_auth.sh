#!/bin/bash

# Скрипт для загрузки файлов аутентификации на сервер
echo "🚀 Загружаем файлы аутентификации на сервер..."

# Настройки сервера
SERVER_URL="https://bulladmin.ru"
API_ENDPOINT="$SERVER_URL/api"

# Проверяем доступность сервера
echo "📡 Проверяем доступность сервера..."
if curl -s -o /dev/null -w "%{http_code}" "$API_ENDPOINT/brands" | grep -q "200"; then
    echo "✅ Сервер доступен"
else
    echo "❌ Сервер недоступен"
    exit 1
fi

# Создаем временную папку для файлов
TEMP_DIR="/tmp/bulladmin_auth_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "📁 Подготавливаем файлы..."

# Копируем файлы аутентификации
cp server_files/User.ts "$TEMP_DIR/"
cp server_files/auth.ts "$TEMP_DIR/"

# Создаем package.json для установки зависимостей
cat > "$TEMP_DIR/package.json" << EOF
{
  "name": "bulladmin-auth",
  "version": "1.0.0",
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6",
    "@types/jsonwebtoken": "^9.0.5"
  }
}
EOF

# Создаем инструкции по установке
cat > "$TEMP_DIR/INSTALL.md" << EOF
# Установка аутентификации

## 1. Установить зависимости:
\`\`\`bash
npm install bcryptjs jsonwebtoken @types/bcryptjs @types/jsonwebtoken
\`\`\`

## 2. Добавить в основной файл сервера:
\`\`\`typescript
import authRoutes from './auth';

// Добавить роутер аутентификации
app.use('/api/auth', authRoutes);
\`\`\`

## 3. Настроить переменные окружения:
\`\`\`bash
JWT_SECRET=your-secret-key-here
JWT_REFRESH_SECRET=your-refresh-secret-key-here
\`\`\`

## 4. Перезапустить сервер
EOF

echo "📦 Создан пакет для загрузки:"
echo "   - User.ts (модель пользователя)"
echo "   - auth.ts (роутер аутентификации)"
echo "   - package.json (зависимости)"
echo "   - INSTALL.md (инструкции)"

echo ""
echo "📤 Файлы готовы для загрузки в: $TEMP_DIR"
echo ""
echo "🔧 Следующие шаги:"
echo "   1. Загрузите файлы на сервер"
echo "   2. Установите зависимости: npm install"
echo "   3. Добавьте роутер в основной файл"
echo "   4. Настройте переменные окружения"
echo "   5. Перезапустите сервер"

# Показываем содержимое файлов
echo ""
echo "📄 Содержимое User.ts:"
echo "---"
head -20 "$TEMP_DIR/User.ts"
echo "---"

echo ""
echo "📄 Содержимое auth.ts:"
echo "---"
head -20 "$TEMP_DIR/auth.ts"
echo "---"

echo ""
echo "✅ Готово! Файлы находятся в: $TEMP_DIR"
