#!/usr/bin/env bash
set -e

echo "=== Запуск веб-тестов Selenium для demoqa.com ==="

if ! command -v mvn >/dev/null 2>&1; then
  echo "Maven не найден. Установите Maven (maven) перед запуском скрипта."
  exit 1
fi

echo "WEB_BROWSER=${WEB_BROWSER:-chrome}"
echo "WEB_BASE_URL=${WEB_BASE_URL:-https://demoqa.com}"

mvn -q -Dtest=web.tests.DemoQaWebTests test

echo "=== Веб-тесты завершены ==="


