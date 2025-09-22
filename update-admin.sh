#!/bin/bash

echo "=== БЫСТРОЕ ОБНОВЛЕНИЕ АДМИНКИ ==="
echo ""

# Проверяем, что мы в правильной директории
if [ ! -f "byk-admin/package.json" ]; then
    echo "❌ Ошибка: Не найдена папка byk-admin"
    exit 1
fi

echo "1. Обновляем код..."
git pull origin main

echo ""
echo "2. Переходим в папку админки..."
cd byk-admin

echo ""
echo "3. Устанавливаем зависимости (если нужно)..."
npm install

echo ""
echo "4. Создаем новую сборку..."
npm run build

echo ""
echo "5. Перезапускаем сервер..."
pkill -f "next start"
sleep 2
nohup npm start > admin.log 2>&1 &

echo "✅ Админка обновлена и перезапущена!"
echo "Проверьте логи: tail -f admin.log"
