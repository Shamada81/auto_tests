#!/usr/bin/env bash
set -e

echo "=== Скачивание Wikipedia APK ==="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIKIPEDIA_APK="${PROJECT_ROOT}/wikipedia.apk"

if [ -f "${WIKIPEDIA_APK}" ]; then
  echo "✅ Wikipedia APK уже существует: ${WIKIPEDIA_APK}"
  exit 0
fi

echo "📥 Скачивание Wikipedia APK..."

# Используем прямую ссылку на последнюю версию Wikipedia
# Версия 50563 (December 12, 2025) - universal
WIKIPEDIA_VERSION="50563"

# Прямая ссылка на скачивание через APKMirror CDN
# Формат: https://d.apkpure.com/b/APK/{package}?version={version}
# Или попробуем через APKMirror напрямую

DOWNLOAD_URLS=(
  "https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=wikipedia&version=${WIKIPEDIA_VERSION}"
  "https://apkmirror.com/apk/wikipedia-foundation/wikipedia/wikipedia-${WIKIPEDIA_VERSION}-release/"
)

if command -v wget >/dev/null 2>&1; then
  echo "Попытка скачать через wget..."
  
  # Сначала получаем HTML страницу
  TEMP_PAGE="/tmp/wikipedia_download_page.html"
  wget -q --timeout=15 -O "${TEMP_PAGE}" \
    --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
    "https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/wikipedia-${WIKIPEDIA_VERSION}-release/wikipedia-${WIKIPEDIA_VERSION}-android-6-0-120-640dpi-release/" 2>/dev/null || true
  
  if [ -f "${TEMP_PAGE}" ] && [ -s "${TEMP_PAGE}" ]; then
    # Ищем data-downloadurl
    DOWNLOAD_URL=$(grep -o 'data-downloadurl="[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/data-downloadurl="//;s/"//' || echo "")
    
    if [ -n "${DOWNLOAD_URL}" ]; then
      echo "Найдена ссылка на скачивание"
      echo "Скачивание APK (это может занять 1-2 минуты)..."
      wget --timeout=120 --tries=2 \
        --progress=bar:force \
        --referer="https://www.apkmirror.com/" \
        --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
        -O "${WIKIPEDIA_APK}" \
        "${DOWNLOAD_URL}" 2>&1 | grep -E "%|wikipedia" || true
      
      rm -f "${TEMP_PAGE}"
      
      if [ -f "${WIKIPEDIA_APK}" ] && [ -s "${WIKIPEDIA_APK}" ]; then
        FILE_SIZE=$(du -h "${WIKIPEDIA_APK}" | cut -f1)
        echo ""
        echo "✅ Wikipedia APK успешно скачан: ${WIKIPEDIA_APK} (${FILE_SIZE})"
        exit 0
      fi
    fi
    rm -f "${TEMP_PAGE}"
  fi
  
  echo "Попытка через альтернативный метод..."
  
elif command -v curl >/dev/null 2>&1; then
  echo "Попытка скачать через curl..."
  
  TEMP_PAGE="/tmp/wikipedia_download_page.html"
  curl -sL --max-time 15 -o "${TEMP_PAGE}" \
    -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
    "https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/wikipedia-${WIKIPEDIA_VERSION}-release/wikipedia-${WIKIPEDIA_VERSION}-android-6-0-120-640dpi-release/" 2>/dev/null || true
  
  if [ -f "${TEMP_PAGE}" ] && [ -s "${TEMP_PAGE}" ]; then
    DOWNLOAD_URL=$(grep -o 'data-downloadurl="[^"]*"' "${TEMP_PAGE}" 2>/dev/null | head -1 | sed 's/data-downloadurl="//;s/"//' || echo "")
    
    if [ -n "${DOWNLOAD_URL}" ]; then
      echo "Найдена ссылка на скачивание"
      echo "Скачивание APK (это может занять 1-2 минуты)..."
      curl -L --max-time 120 \
        --progress-bar \
        -H "Referer: https://www.apkmirror.com/" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
        -o "${WIKIPEDIA_APK}" \
        "${DOWNLOAD_URL}" 2>&1 | grep -E "%|wikipedia" || true
      
      rm -f "${TEMP_PAGE}"
      
      if [ -f "${WIKIPEDIA_APK}" ] && [ -s "${WIKIPEDIA_APK}" ]; then
        FILE_SIZE=$(du -h "${WIKIPEDIA_APK}" | cut -f1)
        echo ""
        echo "✅ Wikipedia APK успешно скачан: ${WIKIPEDIA_APK} (${FILE_SIZE})"
        exit 0
      fi
    fi
    rm -f "${TEMP_PAGE}"
  fi
else
  echo "❌ wget и curl не найдены"
fi

# Попробуем альтернативный способ - через F-Droid или прямое скачивание
echo ""
echo "Попытка скачать через альтернативный источник..."

# Попробуем скачать через apkpure.com (CDN для APK файлов)
APKPURE_URL="https://d.apkpure.com/b/APK/org.wikipedia?version=latest"

if command -v wget >/dev/null 2>&1; then
  echo "Пробуем apkpure.com..."
  wget --timeout=30 --tries=1 \
    --progress=bar:force \
    -O "${WIKIPEDIA_APK}" \
    "${APKPURE_URL}" 2>&1 | grep -E "%|wikipedia" || true
  
  if [ -f "${WIKIPEDIA_APK}" ] && [ -s "${WIKIPEDIA_APK}" ] && file "${WIKIPEDIA_APK}" 2>/dev/null | grep -q "Zip archive\|Android"; then
    FILE_SIZE=$(du -h "${WIKIPEDIA_APK}" | cut -f1)
    echo ""
    echo "✅ Wikipedia APK успешно скачан с apkpure.com: ${WIKIPEDIA_APK} (${FILE_SIZE})"
    exit 0
  fi
  rm -f "${WIKIPEDIA_APK}"
fi

echo ""
echo "❌ Не удалось автоматически скачать Wikipedia APK"
echo ""
echo "РЕКОМЕНДУЕТСЯ один из следующих способов:"
echo ""
echo "📱 Способ 1 (Самый простой): Установить через Google Play на эмуляторе"
echo "   1. Запустите эмулятор: ./scripts/run_mobile_tests.sh (он запустит эмулятор)"
echo "   2. В эмуляторе откройте Google Play Store"
echo "   3. Найдите и установите 'Wikipedia'"
echo "   4. После установки запустите тесты снова"
echo ""
echo "💻 Способ 2: Скачать вручную через браузер"
echo "   1. Откройте: https://www.apkmirror.com/apk/wikipedia-foundation/wikipedia/"
echo "   2. Или: https://f-droid.org/packages/org.wikipedia/"
echo "   3. Скачайте APK (выберите universal версию для Android 6.0+)"
echo "   4. Сохраните как: ${WIKIPEDIA_APK}"
echo ""
echo "⚡ Способ 3: Использовать adb для установки с устройства"
echo "   Если у вас есть физическое устройство с установленным Wikipedia:"
echo "   adb pull \$(adb shell pm path org.wikipedia | cut -d: -f2) wikipedia.apk"
echo ""
echo "После получения APK, тесты будут работать автоматически!"
echo ""
exit 1

