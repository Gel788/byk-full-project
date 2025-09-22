#!/bin/bash

echo "=== ДЕПЛОЙ НА PRODUCTION СЕРВЕР ==="
echo ""
echo "Этот скрипт нужно запустить НА СЕРВЕРЕ для деплоя админки"
echo ""

# Проверяем, что мы в правильной директории
if [ ! -f "byk-admin/package.json" ]; then
    echo "❌ Ошибка: Не найдена папка byk-admin"
    echo "Убедитесь, что вы находитесь в корневой директории проекта"
    exit 1
fi

echo "1. Обновляем код с GitHub..."
git pull origin main

echo ""
echo "2. Переходим в папку админки..."
cd byk-admin

echo ""
echo "3. Устанавливаем зависимости..."
npm install

echo ""
echo "4. Создаем production сборку..."
npm run build

echo ""
echo "5. Останавливаем старый процесс (если запущен)..."
pkill -f "next start" || true

echo ""
echo "6. Запускаем production сервер..."
echo "Админка будет доступна по адресу: http://ваш-домен:3000"
echo ""

# Запускаем в фоновом режиме
nohup npm start > admin.log 2>&1 &

echo "✅ Админка успешно развернута!"
echo "Логи: tail -f byk-admin/admin.log"
echo ""
echo "Для проверки статуса:"
echo "- Проверьте порт 3000: netstat -tlnp | grep 3000"
echo "- Проверьте процессы: ps aux | grep next"
echo ""
echo "Для остановки: pkill -f 'next start'"
