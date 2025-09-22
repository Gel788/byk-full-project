#!/bin/bash

echo "=== БЫСТРЫЙ ДЕПЛОЙ НА СЕРВЕР ==="
echo ""

SERVER_IP="45.12.75.59"
SERVER_USER="root"
SERVER_PASSWORD="%F9xfMkUrb3F"

echo "Подключаемся к серверу и развертываем админку..."

sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'EOF'
echo "Переходим в папку проекта..."
cd /var/www/byk-admin/byk-admin

echo "Обновляем код..."
git pull origin main

echo "Устанавливаем зависимости..."
npm install

echo "Создаем сборку..."
npm run build

echo "Перезапускаем админку..."
pm2 restart byk-admin

echo "Проверяем статус..."
pm2 status
EOF

echo ""
echo "✅ Быстрое обновление завершено!"
echo "🌐 Админка: http://45.12.75.59"
