#!/bin/bash
set -x
# Запуск от root напрямую запрещён, используйте su -c или sudo
if [ "$EUID" -ne 0 ]; then
  echo "Скрипт должен быть запущен с правами root, например, через sudo или su -c" >&2
  exit 1
fi

# Определяем расположение конфига byedpi
CONFIG_PATH="/etc/byedpi.conf"
if [ ! -f "$CONFIG_PATH" ]; then
  if [ -f "/usr/local/etc/byedpi.conf" ]; then
    CONFIG_PATH="/usr/local/etc/byedpi.conf"
  else
    CONFIG_PATH="/etc/byedpi.conf"
  fi
fi

# Проверка наличия пакетного менеджера
if ! command -v apt-get &>/dev/null && ! command -v rpm &>/dev/null; then
  echo "Не найден поддерживаемый пакетный менеджер (apt-get или rpm), выход"
  exit 1
fi

# Проверяем и устанавливаем byedpi из репозитория, если не установлен
if ! command -v byedpi &>/dev/null; then
  echo "byedpi не найден — устанавливаем из репозитория..."
  if command -v apt-get &>/dev/null; then
    apt-get update
    apt-get install -y byedpi
  elif command -v rpm &>/dev/null; then
    yum install -y byedpi
  else
    echo "Не найден подходящий пакетный менеджер для установки byedpi, выход"
    exit 1
  fi
fi

# Конфигурация byedpi
cat > "$CONFIG_PATH" <<EOF
BYEDPI_OPTIONS="-i 127.0.0.1 --port 14228 -Kt,h -s0 -o1 -Ar -o1 -At -f-1 --md5sig -r1+s -As,n -Ku -a5 -An"
EOF

# Включение и запуск сервиса
systemctl enable --now byedpi

echo "ByeDPI успешно установлен и запущен на адресе 127.0.0.1:14228"
echo "Правило и порт можно изменить в $CONFIG_PATH"
echo "Для настройки прокси браузера можно использовать расширения FoxyProxy, SmartProxy или Proxy SwitchyOmega 3"
echo "Готовый бэкап настроек Proxy SwitchyOmega 3 для восстановления можно взять в репозитории скрипта"
echo "systemctl restart byedpi для перезапуска"
echo "systemctl start byedpi для запуска"
echo "systemctl status byedpi для проверки статуса сервиса"
systemctl status byedpi
