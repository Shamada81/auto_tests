#!/bin/bash

set -e

echo "Запуск мобильных тестов"
echo ""

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

echo "1. Проверка эмулятора..."
if $ANDROID_HOME/platform-tools/adb devices 2>/dev/null | grep -q "device$"; then
    DEVICE=$($ANDROID_HOME/platform-tools/adb devices 2>/dev/null | grep "device$" | awk '{print $1}' | head -1)
    echo "   Эмулятор подключен: $DEVICE"
else
    echo "   Эмулятор не подключен"
    echo ""
    echo "   Запустите эмулятор:"
    echo "   $ANDROID_HOME/emulator/emulator -avd test_emulator &"
    exit 1
fi
echo ""

echo "2. Проверка Wikipedia..."
if $ANDROID_HOME/platform-tools/adb shell pm list packages 2>/dev/null | grep -q "org.wikipedia"; then
    echo "   Wikipedia установлена"
else
    echo "   Wikipedia не установлена"
    echo ""
    echo "   Установите APK:"
    echo "   $ANDROID_HOME/platform-tools/adb install wikipedia.apk"
    exit 1
fi
echo ""

echo "3. Проверка Appium Server..."
if curl -s http://localhost:4723/wd/hub/status > /dev/null 2>&1; then
    echo "   Appium Server запущен"
else
    echo "   Appium Server не запущен"
    echo ""
    echo "   Запустите Appium Server:"
    echo "   appium"
    exit 1
fi
echo ""

echo "4. Запуск тестов..."
cd /home/vladimir/Учеba/tests
mvn clean test -Dtest=WikipediaMobileTests

echo ""
echo "Тесты завершены"
echo "Результаты: target/surefire-reports/"
