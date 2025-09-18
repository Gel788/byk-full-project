#!/bin/bash

# Скрипт для подключения к серверу с паролем
echo "Подключаемся к серверу..."

# Используем expect для автоматического ввода пароля
expect << 'EOF'
spawn ssh root@45.12.75.59
expect "password:"
send "%F9xfMkUrb3F\r"
interact
EOF
