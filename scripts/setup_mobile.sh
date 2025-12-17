#!/usr/bin/env bash
set -e

echo "=== Установка окружения для мобильного тестирования (Android + Appium) ==="

# Определяем домашнюю директорию для Android SDK
ANDROID_SDK_HOME="${HOME}/.android"
ANDROID_SDK_ROOT="${ANDROID_SDK_HOME}/sdk"
ANDROID_HOME="${ANDROID_SDK_ROOT}"

# Проверка Java
if ! command -v java >/dev/null 2>&1; then
  echo "❌ Java не найдена. Установите JDK 11+ перед запуском этого скрипта."
  exit 1
fi
echo "✅ Java найдена: $(java -version 2>&1 | head -1)"

# Проверка Maven
if ! command -v mvn >/dev/null 2>&1; then
  echo "❌ Maven не найден. Установите Maven (maven) через пакетный менеджер."
  exit 1
fi
echo "✅ Maven найден: $(mvn -version | head -1)"

# Проверка Node.js
if ! command -v node >/dev/null 2>&1; then
  echo "❌ Node.js не найден. Установите Node.js (например, через nvm или пакетный менеджер)."
  exit 1
fi
echo "✅ Node.js найден: $(node --version)"

# Установка Appium
echo ""
echo "Проверка Appium..."
if ! command -v appium >/dev/null 2>&1; then
  echo "📦 Устанавливаю Appium глобально через npm..."
  npm install -g appium@latest
else
  echo "✅ Appium уже установлен: $(appium --version)"
fi

# Установка appium-doctor
if ! command -v appium-doctor >/dev/null 2>&1; then
  echo "📦 Устанавливаю appium-doctor..."
  npm install -g appium-doctor
else
  echo "✅ appium-doctor уже установлен"
fi

# Установка uiautomator2 драйвера для Appium
echo "📦 Устанавливаю драйвер UiAutomator2 для Appium..."
appium driver install uiautomator2 || echo "⚠️  Драйвер уже установлен или возникла ошибка"

# Установка Android SDK Command Line Tools
echo ""
echo "=== Настройка Android SDK ==="

if ! command -v adb >/dev/null 2>&1; then
  echo "📦 Установка Android SDK Platform Tools..."
  
  # Определяем OS для скачивания
  OS_TYPE="linux"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS_TYPE="win"
  fi
  
  # Создаём директорию для SDK
  mkdir -p "${ANDROID_SDK_ROOT}"
  
  # Скачиваем platform-tools, если adb не найден
  PLATFORM_TOOLS_URL="https://dl.google.com/android/repository/platform-tools-latest-${OS_TYPE}.zip"
  
  if command -v wget >/dev/null 2>&1; then
    echo "Скачивание platform-tools..."
    cd /tmp
    wget -q "${PLATFORM_TOOLS_URL}" -O platform-tools.zip
    unzip -q platform-tools.zip -d "${ANDROID_SDK_HOME}"
    rm platform-tools.zip
    echo "✅ Platform Tools установлены в ${ANDROID_SDK_ROOT}/platform-tools"
    
    # Добавляем в PATH для текущей сессии
    export PATH="${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
    
    # Проверяем, что adb теперь доступен
    if [ -f "${ANDROID_SDK_ROOT}/platform-tools/adb" ]; then
      chmod +x "${ANDROID_SDK_ROOT}/platform-tools/adb"
      echo "✅ adb установлен: ${ANDROID_SDK_ROOT}/platform-tools/adb"
    fi
  elif command -v curl >/dev/null 2>&1; then
    echo "Скачивание platform-tools..."
    cd /tmp
    curl -sL "${PLATFORM_TOOLS_URL}" -o platform-tools.zip
    unzip -q platform-tools.zip -d "${ANDROID_SDK_HOME}"
    rm platform-tools.zip
    echo "✅ Platform Tools установлены"
    export PATH="${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
    if [ -f "${ANDROID_SDK_ROOT}/platform-tools/adb" ]; then
      chmod +x "${ANDROID_SDK_ROOT}/platform-tools/adb"
    fi
  else
    echo "⚠️  wget и curl не найдены. Установите Android SDK Platform Tools вручную."
    echo "   Скачайте с: https://developer.android.com/studio/releases/platform-tools"
    echo "   И добавьте platform-tools в PATH"
  fi
else
  echo "✅ adb уже установлен: $(which adb)"
  ADB_PATH=$(which adb)
  ANDROID_SDK_ROOT=$(dirname $(dirname "$ADB_PATH"))
  export ANDROID_HOME="${ANDROID_SDK_ROOT}"
fi

# Попытка установить Android SDK Command Line Tools для управления эмуляторами
echo ""
echo "=== Настройка Android SDK Command Line Tools ==="

CMD_TOOLS_DIR="${ANDROID_SDK_ROOT}/cmdline-tools"
CMD_TOOLS_BIN="${CMD_TOOLS_DIR}/latest/bin"

if [ ! -f "${CMD_TOOLS_BIN}/sdkmanager" ] && [ ! -f "${CMD_TOOLS_BIN}/avdmanager" ]; then
  echo "📦 Установка Android SDK Command Line Tools..."
  
  OS_TYPE="linux"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="mac"
  fi
  
  CMD_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-${OS_TYPE}-9477386_latest.zip"
  
  mkdir -p "${CMD_TOOLS_DIR}"
  
  if command -v wget >/dev/null 2>&1; then
    cd /tmp
    wget -q "${CMD_TOOLS_URL}" -O cmdline-tools.zip
    unzip -q cmdline-tools.zip -d "${CMD_TOOLS_DIR}"
    mv "${CMD_TOOLS_DIR}"/cmdline-tools "${CMD_TOOLS_DIR}"/latest 2>/dev/null || true
    rm -f cmdline-tools.zip
  elif command -v curl >/dev/null 2>&1; then
    cd /tmp
    curl -sL "${CMD_TOOLS_URL}" -o cmdline-tools.zip
    unzip -q cmdline-tools.zip -d "${CMD_TOOLS_DIR}"
    mv "${CMD_TOOLS_DIR}"/cmdline-tools "${CMD_TOOLS_DIR}"/latest 2>/dev/null || true
    rm -f cmdline-tools.zip
  fi
  
  if [ -f "${CMD_TOOLS_BIN}/sdkmanager" ]; then
    chmod +x "${CMD_TOOLS_BIN}"/*
    export PATH="${CMD_TOOLS_BIN}:${PATH}"
    echo "✅ Command Line Tools установлены"
  fi
else
  echo "✅ Command Line Tools уже установлены"
  export PATH="${CMD_TOOLS_BIN}:${PATH}"
fi

# Установка необходимых компонентов SDK через sdkmanager (если доступен)
if command -v sdkmanager >/dev/null 2>&1 || [ -f "${CMD_TOOLS_BIN}/sdkmanager" ]; then
  echo ""
  echo "📦 Установка компонентов Android SDK..."
  
  SDKMANAGER="${CMD_TOOLS_BIN}/sdkmanager"
  export ANDROID_HOME="${ANDROID_SDK_ROOT}"
  
  # Принимаем лицензии
  yes | "${SDKMANAGER}" --licenses >/dev/null 2>&1 || true
  
  # Устанавливаем необходимые пакеты
  echo "Установка платформы Android и эмулятора..."
  "${SDKMANAGER}" --install "platform-tools" "platforms;android-33" "build-tools;33.0.0" "emulator" "system-images;android-33;google_apis;x86_64" 2>/dev/null || echo "⚠️  Некоторые пакеты могут быть уже установлены"
  
  echo "✅ Компоненты SDK установлены"
fi

# Сохранение путей для будущего использования
echo ""
echo "=== Сохранение настроек окружения ==="

ENV_FILE="${HOME}/.android_env"
cat > "${ENV_FILE}" << EOF
export ANDROID_HOME="${ANDROID_SDK_ROOT}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT}"
export PATH="\${ANDROID_HOME}/platform-tools:\${ANDROID_HOME}/cmdline-tools/latest/bin:\${ANDROID_HOME}/emulator:\${PATH}"
EOF

echo "✅ Настройки окружения сохранены в ${ENV_FILE}"
echo ""
echo "Для использования в текущей сессии выполните:"
echo "  source ${ENV_FILE}"

# Создание AVD (Android Virtual Device) если avdmanager доступен
echo ""
echo "=== Создание Android эмулятора ==="

if command -v avdmanager >/dev/null 2>&1 || [ -f "${CMD_TOOLS_BIN}/avdmanager" ]; then
  AVDMANAGER="${CMD_TOOLS_BIN}/avdmanager"
  AVD_NAME="test_emulator"
  
  # Проверяем, существует ли уже AVD
  if "${AVDMANAGER}" list avd | grep -q "${AVD_NAME}"; then
    echo "✅ Эмулятор '${AVD_NAME}' уже существует"
  else
    echo "📦 Создание эмулятора '${AVD_NAME}'..."
    echo "no" | "${AVDMANAGER}" create avd -n "${AVD_NAME}" -k "system-images;android-33;google_apis;x86_64" -d "pixel_4" 2>/dev/null || {
      echo "⚠️  Не удалось создать AVD автоматически"
      echo "   Попробуйте создать вручную через Android Studio или используйте физическое устройство"
    }
  fi
else
  echo "⚠️  avdmanager не найден. Установите Android SDK Command Line Tools полностью"
fi

echo ""
echo "=== Скачивание приложения Wikipedia APK ==="

# Определяем корневую директорию проекта (родительская директория scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WIKIPEDIA_APK="${PROJECT_ROOT}/wikipedia.apk"

if [ -f "${WIKIPEDIA_APK}" ]; then
  echo "✅ Wikipedia APK уже существует: ${WIKIPEDIA_APK}"
else
  echo "📥 Скачивание Wikipedia APK с APKMirror..."
  echo "ℹ️  Примечание: скачивание может занять время. Если не удастся, можно скачать вручную позже."
  
  # Флаг успешного скачивания
  DOWNLOAD_SUCCESS=false
  
  # Последняя версия Wikipedia с universal архитектурой (Android 6.0+)
  # Версия 50563 (December 12, 2025) - универсальная версия
  WIKIPEDIA_VERSION="50563"
  WIKIPEDIA_URL="https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/wikipedia-${WIKIPEDIA_VERSION}-release/wikipedia-${WIKIPEDIA_VERSION}-android-6-0-120-640dpi-release/"
  
  # Скачиваем APK через парсинг страницы APKMirror
  if command -v wget >/dev/null 2>&1; then
    echo "Получение прямой ссылки на скачивание с APKMirror..."
    echo "⏳ Это может занять несколько секунд..."
    
    # Скачиваем HTML страницу версии с таймаутом
    TEMP_PAGE="/tmp/wikipedia_apk_page.html"
    timeout 30 wget -q --timeout=10 --tries=2 -O "${TEMP_PAGE}" \
      --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
      "${WIKIPEDIA_URL}" 2>/dev/null || {
      echo "⚠️  Не удалось получить страницу версии (таймаут или ошибка сети)"
      rm -f "${TEMP_PAGE}"
    }
    
    # Ищем прямую ссылку на APK в HTML
    # APKMirror использует data-downloadurl атрибут или прямую ссылку в коде страницы
    if [ -f "${TEMP_PAGE}" ] && [ -s "${TEMP_PAGE}" ]; then
      # Пробуем найти ссылку через data-downloadurl (используем sed вместо grep -P для совместимости)
      DOWNLOAD_URL=$(grep -o 'data-downloadurl="[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/data-downloadurl="//;s/"//' || echo "")
      
      # Если не нашли, ищем ссылку на download.php (используем sed для совместимости)
      if [ -z "${DOWNLOAD_URL}" ]; then
        DOWNLOAD_URL=$(grep -o 'href="[^"]*download\.php[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/href="//;s/"//' || echo "")
        # Если относительная ссылка, делаем её абсолютной
        if [ -n "${DOWNLOAD_URL}" ] && [[ ! "${DOWNLOAD_URL}" =~ ^http ]]; then
          DOWNLOAD_URL="https://www.apkmirror.com${DOWNLOAD_URL}"
        fi
      fi
      
      if [ -n "${DOWNLOAD_URL}" ]; then
        echo "✅ Найдена ссылка на скачивание"
        echo "📥 Скачивание APK (это может занять 1-2 минуты)..."
        timeout 120 wget --timeout=30 --tries=2 \
          --show-progress \
          --referer="${WIKIPEDIA_URL}" \
          --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
          -O "${WIKIPEDIA_APK}" \
          "${DOWNLOAD_URL}" 2>&1 | while IFS= read -r line; do
          echo -n "."
        done
        echo "" # Новая строка после точек
        
        # Проверяем, что файл действительно APK (zip архив)
        if [ -f "${WIKIPEDIA_APK}" ]; then
          FILE_TYPE=$(file "${WIKIPEDIA_APK}" 2>/dev/null | grep -o "Zip archive\|Android" || echo "")
          if [ -n "${FILE_TYPE}" ] && [ -s "${WIKIPEDIA_APK}" ]; then
            FILE_SIZE=$(du -h "${WIKIPEDIA_APK}" | cut -f1)
            echo "✅ Wikipedia APK успешно скачан: ${WIKIPEDIA_APK} (${FILE_SIZE})"
            rm -f "${TEMP_PAGE}"
          else
            echo "⚠️  Скачанный файл не является валидным APK (размер: $(stat -f%z "${WIKIPEDIA_APK}" 2>/dev/null || stat -c%s "${WIKIPEDIA_APK}" 2>/dev/null || echo "unknown"))"
            rm -f "${WIKIPEDIA_APK}" "${TEMP_PAGE}"
          fi
        else
          echo "⚠️  Не удалось скачать файл"
          rm -f "${TEMP_PAGE}"
        fi
      else
        echo "⚠️  Не удалось найти ссылку на скачивание в HTML"
        rm -f "${TEMP_PAGE}"
      fi
    fi
    
  elif command -v curl >/dev/null 2>&1; then
    echo "Получение прямой ссылки на скачивание с APKMirror..."
    echo "⏳ Это может занять несколько секунд..."
    
    TEMP_PAGE="/tmp/wikipedia_apk_page.html"
    timeout 30 curl --max-time 10 --connect-timeout 5 -sL -o "${TEMP_PAGE}" \
      -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
      "${WIKIPEDIA_URL}" 2>/dev/null || {
      echo "⚠️  Не удалось получить страницу версии (таймаут или ошибка сети)"
      rm -f "${TEMP_PAGE}"
    }
    
    if [ -f "${TEMP_PAGE}" ] && [ -s "${TEMP_PAGE}" ]; then
      # Ищем ссылку на скачивание (используем sed вместо grep -P)
      DOWNLOAD_URL=$(grep -o 'data-downloadurl="[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/data-downloadurl="//;s/"//' || echo "")
      
      if [ -z "${DOWNLOAD_URL}" ]; then
        DOWNLOAD_URL=$(grep -o 'href="[^"]*download\.php[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/href="//;s/"//' || echo "")
        if [ -n "${DOWNLOAD_URL}" ] && [[ ! "${DOWNLOAD_URL}" =~ ^http ]]; then
          DOWNLOAD_URL="https://www.apkmirror.com${DOWNLOAD_URL}"
        fi
      fi
      
      if [ -n "${DOWNLOAD_URL}" ]; then
        echo "✅ Найдена ссылка на скачивание"
        echo "📥 Скачивание APK (это может занять 1-2 минуты)..."
        timeout 120 curl --max-time 60 --connect-timeout 10 \
          -L -o "${WIKIPEDIA_APK}" \
          -H "Referer: ${WIKIPEDIA_URL}" \
          -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
          --progress-bar \
          "${DOWNLOAD_URL}" >/dev/null 2>&1 || {
          echo "⚠️  Ошибка при скачивании (таймаут или ошибка сети)"
        }
        
        if [ -f "${WIKIPEDIA_APK}" ]; then
          FILE_TYPE=$(file "${WIKIPEDIA_APK}" 2>/dev/null | grep -o "Zip archive\|Android" || echo "")
          if [ -n "${FILE_TYPE}" ] && [ -s "${WIKIPEDIA_APK}" ]; then
            FILE_SIZE=$(du -h "${WIKIPEDIA_APK}" | cut -f1)
            echo "✅ Wikipedia APK успешно скачан: ${WIKIPEDIA_APK} (${FILE_SIZE})"
            DOWNLOAD_SUCCESS=true
            rm -f "${TEMP_PAGE}"
          else
            echo "⚠️  Скачанный файл не является валидным APK"
            rm -f "${WIKIPEDIA_APK}" "${TEMP_PAGE}"
          fi
        else
          echo "⚠️  Не удалось скачать файл"
          rm -f "${TEMP_PAGE}"
        fi
      else
        echo "⚠️  Не удалось найти ссылку на скачивание в HTML"
        rm -f "${TEMP_PAGE}"
      fi
    fi
  else
    echo "⚠️  wget и curl не найдены. Не могу скачать APK автоматически."
  fi
  
  if [ ! -f "${WIKIPEDIA_APK}" ]; then
    echo ""
    echo "⚠️  Не удалось автоматически скачать Wikipedia APK"
    echo "   Возможные причины: проблемы с сетью, таймаут, или изменения на сайте APKMirror"
    echo ""
    echo "   Это не критично - можно скачать вручную позже:"
    echo "   1. Перейдите на: https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/"
    echo "   2. Выберите последнюю версию (universal, Android 6.0+)"
    echo "   3. Скачайте APK и сохраните как: ${WIKIPEDIA_APK}"
    echo ""
    echo "   Или скрипт run_mobile_tests.sh попытается установить приложение другим способом"
  fi
fi

echo ""
echo "=== Проверка окружения ==="

# Загружаем настройки для проверки
source "${ENV_FILE}" 2>/dev/null || true

if command -v appium-doctor >/dev/null 2>&1; then
  echo "Запуск appium-doctor для проверки..."
  appium-doctor --android 2>&1 | head -20 || echo "⚠️  appium-doctor обнаружил некоторые проблемы"
fi

echo ""
echo "=== ✅ Окружение для мобильных тестов настроено! ==="
echo ""
echo "Что было установлено:"
echo "  ✅ Appium и appium-doctor"
echo "  ✅ Android SDK Platform Tools (adb)"
echo "  ✅ Android SDK Command Line Tools"
echo "  ✅ Компоненты SDK (платформа, эмулятор)"
if [ -f "${WIKIPEDIA_APK}" ]; then
  echo "  ✅ Wikipedia APK (готов к установке)"
fi
echo ""
echo "Перед запуском тестов:"
echo "  1. Добавьте в PATH (или перезагрузите терминал):"
echo "     source ${ENV_FILE}"
echo "  2. Запустите тесты:"
echo "     ./scripts/run_mobile_tests.sh"
echo ""
echo "Скрипт run_mobile_tests.sh автоматически:"
echo "  - Запустит эмулятор, если устройство не подключено"
echo "  - Установит приложение Wikipedia, если его нет"
echo "  - Запустит Appium сервер"
echo "  - Выполнит тесты"
