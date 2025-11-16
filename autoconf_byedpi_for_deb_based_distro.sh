#!/bin/bash
set -euo pipefail

# Запуск от root напрямую запрещён, используйте su -c
if [ "$EUID" -eq 0 ]; then
  echo "Не запускайте скрипт от root напрямую, используйте su -c" >&2
  exit 1
fi

# Проверяем, есть ли команда su
if ! command -v su &>/dev/null; then
  echo "Команда su не найдена, выход" >&2
  exit 1
fi

# Определяем расположение конфига byedpi
CONFIG_PATH="/etc/byedpi.conf"
if [ ! -f "$CONFIG_PATH" ]; then
  if [ -f "/usr/local/etc/byedpi.conf" ]; then
    CONFIG_PATH="/usr/local/etc/byedpi.conf"
  else
    # Конфиг отсутствует, будем использовать /etc/byedpi.conf
    CONFIG_PATH="/etc/byedpi.conf"
  fi
fi

# Проверка наличия пакетного менеджера
if ! command -v apt-get &>/dev/null && ! command -v rpm &>/dev/null; then
  echo "Не найден поддерживаемый пакетный менеджер (apt-get или rpm), выход"
  exit 1
fi

# Проверка наличия byedpi и установка из репозитория с помощью su
if ! command -v byedpi &>/dev/null; then
  echo "byedpi не найден — устанавливаем из репозитория..."
  # Для Alt Linux обычно используется apt или rpm, пример с apt-get для демонстрации
  su -c "apt-get update && apt-get install -y byedpi"
fi

# Настройка конфигурации byedpi
su -c "tee $CONFIG_PATH > /dev/null" <<EOF
BYEDPI_OPTIONS="-i 127.0.0.1 --port 14228 -Kt,h -s0 -o1 -Ar -o1 -At -f-1 --md5sig -r1+s -As,n -Ku -a5 -An"
EOF

# Включение и запуск сервиса byedpi
su -c "systemctl enable --now byedpi"

echo "ByeDPI успешно установлен и запущен на адресе 127.0.0.1:14228"
echo "Правило и порт можно изменить в $CONFIG_PATH"
echo "Для настройки прокси браузера можно использовать расширения FoxyProxy, SmartProxy или Proxy SwitchyOmega 3"
echo "Готовый бэкап настроек Proxy SwitchyOmega 3 для восстановления можно взять в репозитории скрипта"
echo "su -c 'systemctl restart byedpi' для перезапуска"
echo "su -c 'systemctl start byedpi' для запуска"
echo "su -c 'systemctl status byedpi' для проверки статуса сервиса"
su -c "systemctl status byedpi"
