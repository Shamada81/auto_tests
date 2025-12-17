#!/usr/bin/env bash
set -e

echo "=== Подготовка окружения для веб-тестирования (Selenium + TestNG) ==="

# Проверка Java (11+)
if command -v java >/dev/null 2>&1; then
  echo "✅ Java обнаружена: $(java -version 2>&1 | head -1)"
else
  echo "⚠️  Java не найдена. Пытаюсь установить openjdk-21-jdk..."
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get update -y && sudo apt-get install -y openjdk-21-jdk || true
  else
    echo "   Установите JDK вручную (например, openjdk-21-jdk) и перезапустите."
  fi
fi

# Проверка Maven
if command -v mvn >/dev/null 2>&1; then
  echo "✅ Maven обнаружен: $(mvn -v | head -1)"
else
  echo "⚠️  Maven не найден. Пытаюсь установить..."
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get install -y maven || true
  else
    echo "   Установите Maven вручную (sudo apt-get install -y maven)."
  fi
fi

# Браузеры: Chrome/Chromium и Firefox
if command -v google-chrome >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1; then
  echo "✅ Chrome/Chromium обнаружен."
else
  echo "⚠️  Chrome/Chromium не найден. Пытаюсь установить chromium-browser..."
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get install -y chromium-browser || true
  else
    echo "   Установите Chrome или Chromium вручную."
  fi
fi

if command -v firefox >/dev/null 2>&1; then
  echo "✅ Firefox обнаружен."
else
  echo "⚠️  Firefox не найден. Пытаюсь установить..."
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get install -y firefox || true
  else
    echo "   Установите Firefox вручную."
  fi
fi

echo ""
echo "=== Предзагрузка зависимостей Maven (без тестов) ==="
mvn -q -DskipTests dependency:resolve || true

echo ""
echo "✅ Окружение для веб-тестов готово. Запускать: ./scripts/run_web_tests.sh"
#!/usr/bin/env bash
set -e

echo "=== Установка окружения для веб-тестирования ==="

if ! command -v java >/dev/null 2>&1; then
  echo "Java не найдена. Установите JDK 11+ перед запуском этого скрипта."
  exit 1
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "Maven не найден. Установите Maven (maven) через пакетный менеджер или вручную."
  exit 1
fi

echo "Драйверы браузера будут автоматически загружены WebDriverManager (без ручной установки)."
echo "Убедитесь, что у вас установлен хотя бы один поддерживаемый браузер (Chrome/Firefox/Edge)."

echo "=== Окружение для веб-тестов готово. ==="


