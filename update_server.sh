#!/bin/bash

echo "🔄 Обновление сервера..."

# Переходим в директорию проекта
cd /root/byk-full-project

echo "📥 Получаем обновления с GitHub..."
git fetch origin
git reset --hard origin/main

echo "🔧 Пересобираем бэкенд..."
cd byk-backend
npm run build

echo "🔧 Пересобираем админку..."
cd ../byk-admin
npm run build

echo "🔄 Перезапускаем сервисы..."
cd /root
pm2 stop all
pm2 start all

echo "✅ Обновление завершено!"
echo "📊 Статус сервисов:"
pm2 status

echo "🌐 Админка доступна по адресу: https://bulladmin.ru"
