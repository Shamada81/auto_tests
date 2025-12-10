#!/bin/bash

set -e

echo "Проверка проекта"
echo ""

echo "1. Проверка Java..."
if command -v java &> /dev/null; then
    java -version 2>&1 | head -1
    echo "   Java установлена"
else
    echo "   Java не найдена"
    exit 1
fi
echo ""

echo "2. Проверка Maven..."
if command -v mvn &> /dev/null; then
    mvn -version 2>&1 | head -1
    echo "   Maven установлен"
else
    echo "   Maven не найден"
    exit 1
fi
echo ""

echo "3. Проверка структуры проекта..."
if [ -f "pom.xml" ]; then
    echo "   pom.xml найден"
else
    echo "   pom.xml не найден"
    exit 1
fi

if [ -f "src/test/resources/config.properties" ]; then
    echo "   config.properties найден"
else
    echo "   config.properties не найден"
    exit 1
fi

if [ -f "src/test/resources/testng.xml" ]; then
    echo "   testng.xml найден"
else
    echo "   testng.xml не найден"
    exit 1
fi

java_files=$(find src/test/java -name "*.java" 2>/dev/null | wc -l)
echo "   Найдено Java файлов: $java_files"
echo ""

echo "4. Компиляция проекта..."
if mvn clean compile -q > /dev/null 2>&1; then
    echo "   Проект успешно скомпилирован"
else
    echo "   Ошибка компиляции"
    exit 1
fi
echo ""

echo "5. Проверка зависимостей Maven..."
if mvn dependency:resolve -q > /dev/null 2>&1; then
    echo "   Все зависимости загружены"
else
    echo "   Некоторые зависимости могут отсутствовать"
fi
echo ""

echo "6. Проверка веб-тестов..."
web_test_file="src/test/java/tests/web/LentaRuWebTests.java"
if [ -f "$web_test_file" ]; then
    test_count=$(grep -c "@Test" "$web_test_file" 2>/dev/null || echo "0")
    echo "   Файл веб-тестов найден"
    echo "   Найдено тестовых методов: $test_count"
else
    echo "   Файл веб-тестов не найден"
fi
echo ""

echo "7. Проверка мобильных тестов..."
mobile_test_file="src/test/java/tests/mobile/WikipediaMobileTests.java"
if [ -f "$mobile_test_file" ]; then
    test_count=$(grep -c "@Test" "$mobile_test_file" 2>/dev/null || echo "0")
    echo "   Файл мобильных тестов найден"
    echo "   Найдено тестовых методов: $test_count"
else
    echo "   Файл мобильных тестов не найден"
fi
echo ""

echo "8. Проверка Page Object классов..."
web_pages=$(find src/test/java/pages/web -name "*.java" 2>/dev/null | wc -l)
mobile_pages=$(find src/test/java/pages/mobile -name "*.java" 2>/dev/null | wc -l)
echo "   Веб Page Object классов: $web_pages"
echo "   Мобильных Page Object классов: $mobile_pages"
echo ""

echo "9. Проверка документации..."
if [ -f "README.md" ]; then
    echo "   README.md найден"
else
    echo "   README.md не найден"
fi
echo ""

echo "Проверка завершена"
echo ""
