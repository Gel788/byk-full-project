#!/bin/bash

echo "🚀 Полное обновление сервера БЫК Holding..."

# Переходим в директорию проекта
cd /root/byk-full-project

echo "📥 Принудительно обновляем код с GitHub..."
git fetch origin
git reset --hard origin/main

echo "📁 Проверяем наличие новых файлов..."
ls -la byk-backend/src/models/
ls -la byk-backend/src/routes/

echo "🔧 Устанавливаем зависимости бэкенда..."
cd byk-backend
npm install

echo "🔧 Пересобираем бэкенд..."
npm run build

echo "🔧 Устанавливаем зависимости админки..."
cd ../byk-admin
npm install

echo "🔧 Пересобираем админку..."
npm run build

echo "🔄 Останавливаем все сервисы..."
cd /root
pm2 stop all

echo "🔄 Запускаем сервисы заново..."
pm2 start all

echo "📊 Статус сервисов:"
pm2 status

echo "📋 Логи последних 10 строк:"
pm2 logs --lines 10

echo "✅ Обновление завершено!"
echo "🌐 Админка доступна по адресу: https://bulladmin.ru"
echo "🔗 API доступно по адресу: https://bulladmin.ru/api/"

echo ""
echo "🧪 Тестируем новые эндпоинты:"
curl -s https://bulladmin.ru/api/brands | head -100
echo ""
curl -s https://bulladmin.ru/api/cities | head -100
echo ""
curl -s https://bulladmin.ru/api/categories | head -100
