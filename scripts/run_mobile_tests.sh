#!/usr/bin/env bash
set -e

echo "=== Запуск Appium-сервера и мобильных тестов Wikipedia ==="

APPIUM_PORT="${APPIUM_PORT:-4723}"
EMULATOR_NAME="test_emulator"
WIKIPEDIA_PACKAGE="org.wikipedia"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Загрузка настроек окружения Android (если есть)
if [ -f "${HOME}/.android_env" ]; then
  echo "Загрузка настроек окружения Android..."
  source "${HOME}/.android_env"
fi

# Проверка наличия необходимых инструментов
if ! command -v appium >/dev/null 2>&1; then
  echo "❌ Appium не найден. Сначала запустите: ./scripts/setup_mobile.sh"
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "❌ adb не найден. Запустите: ./scripts/setup_mobile.sh"
  exit 1
fi

# Проверка подключенных устройств
echo ""
echo "=== Проверка подключенных Android устройств ==="
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
EMULATOR_PID=""

if [ "$DEVICES" -eq 0 ]; then
  echo "⚠️  Устройства не подключены. Попытка запустить эмулятор..."
  
  # Пытаемся найти эмулятор
  if command -v emulator >/dev/null 2>&1; then
    EMULATOR_CMD="emulator"
  elif [ -n "${ANDROID_HOME}" ] && [ -f "${ANDROID_HOME}/emulator/emulator" ]; then
    EMULATOR_CMD="${ANDROID_HOME}/emulator/emulator"
  elif [ -f "${HOME}/.android/sdk/emulator/emulator" ]; then
    EMULATOR_CMD="${HOME}/.android/sdk/emulator/emulator"
  else
    echo "❌ Эмулятор не найден. Убедитесь, что установлен Android SDK"
    echo "   Запустите: ./scripts/setup_mobile.sh"
    exit 1
  fi
  
  # Проверяем наличие AVD
  if command -v avdmanager >/dev/null 2>&1; then
    AVD_LIST=$(avdmanager list avd 2>/dev/null | grep -c "Name:" || echo "0")
    if [ "$AVD_LIST" -eq 0 ]; then
      echo "❌ AVD не найдены. Создайте эмулятор:"
      echo "   Запустите: ./scripts/setup_mobile.sh"
      exit 1
    fi
  fi
  
  # Запускаем эмулятор
  echo "🚀 Запуск эмулятора '${EMULATOR_NAME}'..."
  
  # Пытаемся найти подходящий AVD
  if command -v avdmanager >/dev/null 2>&1; then
    AVD_NAME=$(avdmanager list avd 2>/dev/null | grep "Name:" | head -1 | awk '{print $2}' || echo "${EMULATOR_NAME}")
  else
    AVD_NAME="${EMULATOR_NAME}"
  fi
  
  echo "Используем AVD: ${AVD_NAME}"
  
  # Запускаем эмулятор в фоне
  "${EMULATOR_CMD}" -avd "${AVD_NAME}" -no-snapshot-load -wipe-data >/dev/null 2>&1 &
  EMULATOR_PID=$!
  
  echo "⏳ Ожидание запуска эмулятора (это может занять 1-2 минуты)..."
  
  # Ждём, пока эмулятор запустится
  TIMEOUT=120
  ELAPSED=0
  while [ $ELAPSED -lt $TIMEOUT ]; do
    if adb devices | grep -q "emulator.*device$"; then
  echo "✅ Эмулятор запущен и готов!"
      break
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    echo "   Ожидание... (${ELAPSED}/${TIMEOUT} сек)"
  done
  
  if ! adb devices | grep -q "emulator.*device$"; then
    echo "❌ Эмулятор не запустился за ${TIMEOUT} секунд"
    if [ -n "${EMULATOR_PID}" ]; then
      kill "${EMULATOR_PID}" 2>/dev/null || true
    fi
    exit 1
  fi
else
  echo "✅ Найдено подключенных устройств: $DEVICES"
fi

# Дополнительно ждём полной загрузки и разблокировки эмулятора
echo ""
echo "=== Проверка готовности эмулятора ==="
adb wait-for-device >/dev/null 2>&1

BOOT_COMPLETED=false
for i in {1..60}; do
  if adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
    BOOT_COMPLETED=true
    break
  fi
  sleep 2
done

if [ "$BOOT_COMPLETED" = false ]; then
  echo "❌ Эмулятор не успел полностью загрузиться (sys.boot_completed)"
  exit 1
fi

# Разблокируем экран, если он заблокирован
adb shell input keyevent 82 >/dev/null 2>&1 || true
adb shell wm dismiss-keyguard >/dev/null 2>&1 || true

# Проверка и установка Appium Settings (ОБЯЗАТЕЛЬНО для UiAutomator2)
echo ""
echo "=== Проверка Appium Settings ==="
if adb shell pm list packages 2>/dev/null | grep -q "io.appium.settings"; then
  echo "✅ Appium Settings уже установлен на устройстве"
  adb shell am broadcast -a io.appium.settings.intent.action.START_SERVICE >/dev/null 2>&1 || true
  adb shell am broadcast -a io.appium.settings.intent.action.CHANGE_PERMISSION -e permission android.permission.WRITE_SECURE_SETTINGS -e enable true >/dev/null 2>&1 || true
  adb shell pm grant io.appium.settings android.permission.WRITE_SECURE_SETTINGS >/dev/null 2>&1 || true
  adb shell pm grant io.appium.settings android.permission.CHANGE_CONFIGURATION >/dev/null 2>&1 || true
  adb shell am start -n io.appium.settings/.Settings >/dev/null 2>&1 || true
else
  echo "ℹ️  Appium Settings не установлен. Пытаюсь установить автоматически..."

  APPIUM_SETTINGS_APK=""

  # Стандартный путь установки Appium Settings в Appium 2.x
  if [ -f "${HOME}/.appium/node_modules/appium-uiautomator2-driver/node_modules/io.appium.settings/apks/settings_apk-debug.apk" ]; then
    APPIUM_SETTINGS_APK="${HOME}/.appium/node_modules/appium-uiautomator2-driver/node_modules/io.appium.settings/apks/settings_apk-debug.apk"
  else
    # Пробуем найти через find (ограничиваем глубину для скорости)
    APPIUM_SETTINGS_APK=$(find "${HOME}/.appium" "${HOME}/.nvm" -maxdepth 6 -type f -name "settings_apk-debug.apk" 2>/dev/null | head -1 || echo "")
  fi

  if [ -n "${APPIUM_SETTINGS_APK}" ] && [ -f "${APPIUM_SETTINGS_APK}" ]; then
    echo "  Найден APK Appium Settings: ${APPIUM_SETTINGS_APK}"
    
    # Убеждаемся, что устройство готово
    echo "  Проверка готовности устройства..."
    adb wait-for-device >/dev/null 2>&1
    for i in {1..10}; do
      if adb shell "echo test" >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done
    
    echo "  Принудительная переустановка Appium Settings..."
    adb shell pm uninstall io.appium.settings >/dev/null 2>&1 || true
    
    INSTALL_LOG="/tmp/appium_settings_install_$$.log"
    INSTALL_SUCCESS=false
    
    # Основной способ установки
    if timeout 120 adb install -r -g -t "${APPIUM_SETTINGS_APK}" >"${INSTALL_LOG}" 2>&1; then
      INSTALL_SUCCESS=true
    else
      echo "  Основная установка не удалась, пробую альтернативный метод (pm install)..."
      timeout 90 adb shell "pm install -r '${APPIUM_SETTINGS_APK}'" >>"${INSTALL_LOG}" 2>&1 || true
      if adb shell pm list packages 2>/dev/null | grep -q "io.appium.settings"; then
        INSTALL_SUCCESS=true
      fi
    fi

    # Финальная проверка установки
    if adb shell pm list packages 2>/dev/null | grep -q "io.appium.settings"; then
      INSTALL_SUCCESS=true
    fi

    if [ "${INSTALL_SUCCESS}" = "true" ]; then
      echo "✅ Appium Settings успешно установлен на устройстве"
      # Выдаём обязательные разрешения и запускаем сервис
      adb shell pm grant io.appium.settings android.permission.WRITE_SECURE_SETTINGS >/dev/null 2>&1 || true
      adb shell pm grant io.appium.settings android.permission.CHANGE_CONFIGURATION >/dev/null 2>&1 || true
      adb shell pm grant io.appium.settings android.permission.DUMP >/dev/null 2>&1 || true
      adb shell am broadcast -a io.appium.settings.intent.action.START_SERVICE >/dev/null 2>&1 || true
      adb shell am start -n io.appium.settings/.Settings >/dev/null 2>&1 || true
    else
      echo "⚠️  Не удалось установить Appium Settings автоматически"
      if [ -f "${INSTALL_LOG}" ]; then
        INSTALL_OUTPUT=$(cat "${INSTALL_LOG}" 2>/dev/null || echo "")
        if [ -n "${INSTALL_OUTPUT}" ]; then
          echo "   Последние строки вывода:"
          echo "${INSTALL_OUTPUT}" | tail -5 | sed 's/^/   /'
        fi
        rm -f "${INSTALL_LOG}" 2>/dev/null || true
      fi
      echo "   Попробуйте вручную:"
      echo "     adb install -r -g -t \"${APPIUM_SETTINGS_APK}\""
      echo ""
      echo "⚠️  Appium может попытаться установить его автоматически при создании сессии."
    fi
  else
    echo "❌ Не удалось найти APK Appium Settings (settings_apk-debug.apk)"
    echo "   Убедитесь, что установлен драйвер uiautomator2:"
    echo "     appium driver install uiautomator2"
  fi
fi

# Проверка и установка приложения Wikipedia
echo ""
echo "=== Проверка приложения Wikipedia ==="

if ! adb shell pm list packages 2>/dev/null | grep -q "${WIKIPEDIA_PACKAGE}"; then
  echo "⚠️  Приложение Wikipedia не найдено. Попытка установить..."
  
  # Определяем пути к проекту и APK
  WIKIPEDIA_APK="${PROJECT_ROOT}/wikipedia.apk"
  
  # Функция для скачивания Wikipedia APK
  download_wikipedia_apk() {
    local APK_FILE="$1"
    local DOWNLOAD_SUCCESS=false
    
    echo "📥 Попытка автоматически скачать Wikipedia APK..."
    
    # Метод 1: Прямая ссылка через F-Droid CDN (самый надежный)
    F_DROID_URL="https://f-droid.org/repo/org.wikipedia_50563.apk"
    echo "  Попытка 1: Скачивание с F-Droid CDN (до 3 минут)..."
    
    if command -v wget >/dev/null 2>&1; then
      DOWNLOAD_OUTPUT=$(timeout 180 wget --timeout=120 --tries=3 --progress=bar:force:noscroll -O "${APK_FILE}" "${F_DROID_URL}" 2>&1)
      WGET_EXIT=$?
      
      if [ $WGET_EXIT -eq 0 ] || echo "$DOWNLOAD_OUTPUT" | grep -qE "(saved|100%)"; then
        if [ -f "${APK_FILE}" ] && [ -s "${APK_FILE}" ]; then
          FILE_SIZE=$(stat -c%s "${APK_FILE}" 2>/dev/null || echo 0)
          if [ $FILE_SIZE -gt 1000000 ]; then
            FILE_TYPE=$(file "${APK_FILE}" 2>/dev/null | grep -oE "(Zip archive|Android|Java archive)" || echo "")
            if [ -n "${FILE_TYPE}" ]; then
              DOWNLOAD_SUCCESS=true
              echo "  ✅ APK успешно скачан с F-Droid ($(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "${FILE_SIZE} bytes"))"
              return 0
            fi
          fi
        fi
      fi
    elif command -v curl >/dev/null 2>&1; then
      if timeout 180 curl -L --max-time 120 --progress-bar -o "${APK_FILE}" "${F_DROID_URL}" 2>&1; then
        if [ -f "${APK_FILE}" ] && [ -s "${APK_FILE}" ]; then
          FILE_SIZE=$(stat -c%s "${APK_FILE}" 2>/dev/null || echo 0)
          if [ $FILE_SIZE -gt 1000000 ]; then
            FILE_TYPE=$(file "${APK_FILE}" 2>/dev/null | grep -oE "(Zip archive|Android|Java archive)" || echo "")
            if [ -n "${FILE_TYPE}" ]; then
              DOWNLOAD_SUCCESS=true
              echo "  ✅ APK успешно скачан с F-Droid ($(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "${FILE_SIZE} bytes"))"
              return 0
            fi
          fi
        fi
      fi
    fi
    
    # Метод 2: Через APKMirror (парсинг страницы)
    local WIKIPEDIA_VERSION="50563"
    if command -v wget >/dev/null 2>&1; then
      echo "  Попытка 2: Скачивание с APKMirror..."
      TEMP_PAGE="/tmp/wikipedia_apk_page.html"
      
      timeout 30 wget -q --timeout=10 -O "${TEMP_PAGE}" \
        --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
        "https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/wikipedia-${WIKIPEDIA_VERSION}-release/wikipedia-${WIKIPEDIA_VERSION}-android-6-0-120-640dpi-release/" 2>/dev/null || true
      
      if [ -f "${TEMP_PAGE}" ] && [ -s "${TEMP_PAGE}" ]; then
        DOWNLOAD_URL=$(grep -o 'data-downloadurl="[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/data-downloadurl="//;s/"//' || echo "")
        
        if [ -n "${DOWNLOAD_URL}" ]; then
          echo "  Найдена ссылка, скачивание..."
          timeout 120 wget --timeout=60 --tries=1 \
            --progress=dot:giga \
            --referer="https://www.apkmirror.com/" \
            --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
            -O "${APK_FILE}" \
            "${DOWNLOAD_URL}" >/dev/null 2>&1 || true
          
          if [ -f "${APK_FILE}" ] && [ -s "${APK_FILE}" ]; then
            FILE_TYPE=$(file "${APK_FILE}" 2>/dev/null | grep -o "Zip archive\|Android" || echo "")
            if [ -n "${FILE_TYPE}" ]; then
              DOWNLOAD_SUCCESS=true
              echo "  ✅ APK успешно скачан"
            fi
          fi
        fi
        rm -f "${TEMP_PAGE}"
      fi
      
      # Метод 3: Попробуем apkpure.com если предыдущие не сработали
      if [ "$DOWNLOAD_SUCCESS" = false ]; then
        echo "  Попытка 3: Скачивание с apkpure.com..."
        APKPURE_URL="https://d.apkpure.com/b/APK/org.wikipedia?version=latest"
        timeout 60 wget --timeout=30 --tries=1 \
          --progress=dot:giga \
          -O "${APK_FILE}" \
          "${APKPURE_URL}" >/dev/null 2>&1 || true
        
        if [ -f "${APK_FILE}" ] && [ -s "${APK_FILE}" ]; then
          FILE_TYPE=$(file "${APK_FILE}" 2>/dev/null | grep -o "Zip archive\|Android" || echo "")
          if [ -n "${FILE_TYPE}" ]; then
            DOWNLOAD_SUCCESS=true
            echo "  ✅ APK успешно скачан с apkpure.com"
          fi
        fi
      fi
      
    elif command -v curl >/dev/null 2>&1; then
      echo "  Попытка скачать через curl..."
      TEMP_PAGE="/tmp/wikipedia_apk_page.html"
      
      timeout 30 curl -sL --max-time 10 -o "${TEMP_PAGE}" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
        "https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/wikipedia-${WIKIPEDIA_VERSION}-release/wikipedia-${WIKIPEDIA_VERSION}-android-6-0-120-640dpi-release/" 2>/dev/null || true
      
      if [ -f "${TEMP_PAGE}" ] && [ -s "${TEMP_PAGE}" ]; then
        DOWNLOAD_URL=$(grep -o 'data-downloadurl="[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/data-downloadurl="//;s/"//' || echo "")
        
        if [ -n "${DOWNLOAD_URL}" ]; then
          timeout 120 curl -L --max-time 60 \
            --progress-bar \
            -H "Referer: https://www.apkmirror.com/" \
            -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
            -o "${APK_FILE}" \
            "${DOWNLOAD_URL}" >/dev/null 2>&1 || true
          
          if [ -f "${APK_FILE}" ] && [ -s "${APK_FILE}" ]; then
            FILE_TYPE=$(file "${APK_FILE}" 2>/dev/null | grep -o "Zip archive\|Android" || echo "")
            if [ -n "${FILE_TYPE}" ]; then
              DOWNLOAD_SUCCESS=true
              echo "  ✅ APK успешно скачан"
            fi
          fi
        fi
        rm -f "${TEMP_PAGE}"
      fi
    fi
    
    if [ "$DOWNLOAD_SUCCESS" = false ]; then
      rm -f "${APK_FILE}"
      return 1
    fi
    return 0
  }
  
  # Проверяем, есть ли APK в проекте
  if [ ! -f "${WIKIPEDIA_APK}" ]; then
    # Пробуем найти в других местах
    if [ -f "wikipedia.apk" ]; then
      WIKIPEDIA_APK="wikipedia.apk"
    elif [ -f "scripts/wikipedia.apk" ]; then
      WIKIPEDIA_APK="scripts/wikipedia.apk"
    else
      # Пытаемся скачать автоматически
      if download_wikipedia_apk "${WIKIPEDIA_APK}"; then
        echo "✅ Wikipedia APK успешно скачан и готов к установке"
      else
        echo ""
        echo "⚠️  Не удалось автоматически скачать Wikipedia APK"
        echo ""
        echo "Рекомендуется установить приложение одним из способов:"
        echo "1. 📱 Установить через Google Play на эмуляторе (самый простой способ)"
        echo "2. 💻 Скачать вручную:"
        echo "   - https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/"
        echo "   - Сохранить как: ${WIKIPEDIA_APK}"
        echo "   - Затем запустить этот скрипт снова"
        echo ""
        echo "Продолжаем выполнение (тесты могут упасть, если приложение не установлено)..."
        WIKIPEDIA_APK=""
      fi
    fi
  else
    echo "✅ Найден локальный APK файл: ${WIKIPEDIA_APK}"
  fi
  
  # Устанавливаем APK, если он есть
  if [ -n "${WIKIPEDIA_APK}" ] && [ -f "${WIKIPEDIA_APK}" ]; then
    echo "📦 Установка Wikipedia из APK (это может занять 30-60 секунд)..."
    
    # Запускаем установку в фоне с таймаутом
    (
      timeout 120 adb install -r "${WIKIPEDIA_APK}" >/tmp/wikipedia_install.log 2>&1
      INSTALL_EXIT=$?
      echo $INSTALL_EXIT > /tmp/wikipedia_install_exit.txt
    ) &
    INSTALL_PID=$!
    
    # Ждём максимум 2 минуты с проверкой каждые 5 секунд
    MAX_WAIT=120
    ELAPSED=0
    INSTALLED=false
    
    while [ $ELAPSED -lt $MAX_WAIT ]; do
      sleep 5
      ELAPSED=$((ELAPSED + 5))
      
      # Проверяем, установлено ли приложение
      if adb shell pm list packages 2>/dev/null | grep -q "${WIKIPEDIA_PACKAGE}"; then
        INSTALLED=true
        kill $INSTALL_PID 2>/dev/null || true
        wait $INSTALL_PID 2>/dev/null || true
        echo "✅ Приложение Wikipedia успешно установлено (за ${ELAPSED} сек)"
        break
      fi
      
      # Проверяем, завершилась ли команда установки
      if ! kill -0 $INSTALL_PID 2>/dev/null; then
        # Процесс завершился, проверяем результат
        if [ -f /tmp/wikipedia_install_exit.txt ]; then
          INSTALL_EXIT=$(cat /tmp/wikipedia_install_exit.txt 2>/dev/null || echo "1")
          rm -f /tmp/wikipedia_install_exit.txt
          
          if [ "$INSTALL_EXIT" = "0" ] || adb shell pm list packages 2>/dev/null | grep -q "${WIKIPEDIA_PACKAGE}"; then
            INSTALLED=true
            echo "✅ Приложение Wikipedia успешно установлено"
            break
          else
            echo "⚠️  Установка завершилась с ошибкой. Пробуем альтернативный метод..."
            timeout 60 adb shell "pm install -r ${WIKIPEDIA_APK}" >/dev/null 2>&1
            if adb shell pm list packages 2>/dev/null | grep -q "${WIKIPEDIA_PACKAGE}"; then
              INSTALLED=true
              echo "✅ Установлено альтернативным методом"
              break
            fi
          fi
        fi
        break
      fi
      
      echo -n "."
    done
    
    # Если процесс еще работает, убиваем его
    kill $INSTALL_PID 2>/dev/null || true
    wait $INSTALL_PID 2>/dev/null || true
    rm -f /tmp/wikipedia_install_exit.txt /tmp/wikipedia_install.log
    
    if [ "$INSTALLED" = false ]; then
      echo ""
      echo "⚠️  Не удалось установить APK в течение $MAX_WAIT секунд"
      echo "   Приложение будет установлено автоматически Appium при создании сессии"
    fi
  fi
else
  echo "✅ Приложение Wikipedia уже установлено на устройстве"
fi

# Проверка и запуск Appium сервера
echo ""
echo "=== Запуск Appium сервера ==="

# Проверка, не занят ли порт
PORT_OCCUPIED=false
if command -v lsof >/dev/null 2>&1; then
  if lsof -Pi :"${APPIUM_PORT}" -sTCP:LISTEN -t >/dev/null 2>&1; then
    PORT_OCCUPIED=true
  fi
elif command -v netstat >/dev/null 2>&1; then
  if netstat -an 2>/dev/null | grep -q ":${APPIUM_PORT}.*LISTEN"; then
    PORT_OCCUPIED=true
  fi
fi

if [ "$PORT_OCCUPIED" = true ]; then
  echo "⚠️  Порт ${APPIUM_PORT} уже занят. Попытка завершить старый процесс Appium..."
  pkill -f "appium.*-p.*${APPIUM_PORT}" 2>/dev/null || true
  sleep 2
  
  # Если порт всё ещё занят, используем другой порт
  sleep 2
  PORT_STILL_OCCUPIED=false
  if command -v lsof >/dev/null 2>&1; then
    if lsof -Pi :"${APPIUM_PORT}" -sTCP:LISTEN -t >/dev/null 2>&1; then
      PORT_STILL_OCCUPIED=true
    fi
  elif command -v netstat >/dev/null 2>&1; then
    if netstat -an 2>/dev/null | grep -q ":${APPIUM_PORT}.*LISTEN"; then
      PORT_STILL_OCCUPIED=true
    fi
  fi
  
  if [ "$PORT_STILL_OCCUPIED" = true ]; then
    APPIUM_PORT=$((APPIUM_PORT + 1))
    echo "Используем альтернативный порт: ${APPIUM_PORT}"
  fi
fi

# Определяем версию Appium и используем соответствующий URL
APPIUM_VERSION=$(appium --version 2>/dev/null | head -1 || echo "2.0")
# Appium 2.x не использует /wd/hub, версии 1.x используют
if [[ "${APPIUM_VERSION}" =~ ^1\. ]]; then
  export APPIUM_SERVER_URL="http://127.0.0.1:${APPIUM_PORT}/wd/hub"
else
  export APPIUM_SERVER_URL="http://127.0.0.1:${APPIUM_PORT}"
fi

echo "Запуск Appium на порту ${APPIUM_PORT}..."
appium -p "${APPIUM_PORT}" --log-level error >/dev/null 2>&1 &
APPIUM_PID=$!

# Ждём, пока Appium запустится
echo "⏳ Ожидание запуска Appium сервера..."
sleep 5

# Проверка, что Appium действительно запустился
if ! ps -p "${APPIUM_PID}" > /dev/null 2>&1; then
  echo "❌ Ошибка: Appium сервер не запустился"
  echo "   Проверьте, что Appium установлен: npm install -g appium"
  exit 1
fi

# Дополнительная проверка доступности сервера
# Appium 2.x использует корневой путь, 1.x использует /status
STATUS_ENDPOINT="/"
if [[ "${APPIUM_VERSION}" =~ ^1\. ]]; then
  STATUS_ENDPOINT="/status"
fi

if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
  TIMEOUT=30
  ELAPSED=0
  while [ $ELAPSED -lt $TIMEOUT ]; do
    if command -v curl >/dev/null 2>&1; then
      if curl -s "http://127.0.0.1:${APPIUM_PORT}${STATUS_ENDPOINT}" >/dev/null 2>&1; then
        echo "✅ Appium сервер запущен и доступен (PID: ${APPIUM_PID}, версия: ${APPIUM_VERSION})"
        echo "   URL: ${APPIUM_SERVER_URL}"
        break
      fi
    elif command -v wget >/dev/null 2>&1; then
      if wget -q --spider "http://127.0.0.1:${APPIUM_PORT}${STATUS_ENDPOINT}" >/dev/null 2>&1; then
        echo "✅ Appium сервер запущен и доступен (PID: ${APPIUM_PID}, версия: ${APPIUM_VERSION})"
        echo "   URL: ${APPIUM_SERVER_URL}"
        break
      fi
    else
      # Если ни curl, ни wget нет, просто ждём и продолжаем
      break
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
  done
  
  if [ $ELAPSED -eq $TIMEOUT ]; then
    echo "⚠️  Appium сервер запущен, но не отвечает на проверку. Продолжаем..."
    echo "   Используется URL: ${APPIUM_SERVER_URL}"
  fi
else
  echo "✅ Appium сервер запущен (PID: ${APPIUM_PID}, версия: ${APPIUM_VERSION})"
  echo "   URL: ${APPIUM_SERVER_URL}"
fi

# Функция очистки при выходе
cleanup() {
  echo ""
  echo "=== Очистка ресурсов ==="
  
  if [ -n "${APPIUM_PID}" ]; then
    echo "Остановка Appium сервера..."
    kill "${APPIUM_PID}" 2>/dev/null || true
    sleep 2
  fi
  
  if [ -n "${EMULATOR_PID}" ]; then
    echo "Остановка эмулятора..."
    adb emu kill 2>/dev/null || kill "${EMULATOR_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

# Запуск тестов
echo ""
echo "=== Запуск мобильных тестов Wikipedia ==="
echo "Appium URL: ${APPIUM_SERVER_URL}"
echo "Устройство: $(adb devices | grep 'device$' | head -1 | awk '{print $1}')"
echo ""

(cd "${PROJECT_ROOT}" && mvn -q clean -Dtest=mobile.tests.WikipediaMobileTests test)

echo ""
echo "=== ✅ Мобильные тесты завершены ==="
