#!/bin/bash

echo "=== ДЕПЛОЙ АДМИНКИ НА СЕРВЕР ==="
echo ""

# Данные сервера
SERVER_IP="45.12.75.59"
SERVER_USER="root"
SERVER_PASSWORD="%F9xfMkUrb3F"

echo "Подключаемся к серверу: $SERVER_IP"
echo "Пользователь: $SERVER_USER"
echo ""

# Устанавливаем sshpass если не установлен
if ! command -v sshpass &> /dev/null; then
    echo "Устанавливаем sshpass..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install hudochenkov/sshpass/sshpass
    else
        # Linux
        sudo apt-get update && sudo apt-get install -y sshpass
    fi
fi

echo "1. Подключаемся к серверу и обновляем систему..."
sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'EOF'
echo "Обновляем систему..."
apt update && apt upgrade -y

echo "Устанавливаем Node.js и npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs

echo "Устанавливаем Git..."
apt install -y git

echo "Устанавливаем PM2 для управления процессами..."
npm install -g pm2

echo "Создаем директорию для проекта..."
mkdir -p /var/www/byk-admin
cd /var/www/byk-admin

echo "Клонируем репозиторий..."
git clone https://github.com/Gel788/byk-full-project.git .

echo "Переходим в папку админки..."
cd byk-admin

echo "Устанавливаем зависимости..."
npm install

echo "Создаем production сборку..."
npm run build

echo "Настраиваем PM2 для автозапуска..."
pm2 start npm --name "byk-admin" -- start
pm2 save
pm2 startup

echo "Настраиваем Nginx..."
apt install -y nginx

cat > /etc/nginx/sites-available/byk-admin << 'NGINX_EOF'
server {
    listen 80;
    server_name 45.12.75.59;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_EOF

ln -sf /etc/nginx/sites-available/byk-admin /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
systemctl enable nginx

echo "Настраиваем firewall..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

echo "✅ Админка успешно развернута!"
echo "Доступна по адресу: http://45.12.75.59"
echo "Статус PM2:"
pm2 status
EOF

echo ""
echo "✅ ДЕПЛОЙ ЗАВЕРШЕН!"
echo ""
echo "🌐 Админка доступна по адресу: http://45.12.75.59"
echo "🔐 Логин: albgel@yandex.ru"
echo "🔑 Пароль: 123456"
echo ""
echo "📊 Для мониторинга на сервере:"
echo "   pm2 status          - статус процессов"
echo "   pm2 logs byk-admin  - логи админки"
echo "   pm2 restart byk-admin - перезапуск"
