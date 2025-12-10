#!/bin/bash

set -e

echo "Установка зависимостей"
echo ""

echo "Обновление системы..."
sudo apt update

echo "Проверка установки JDK..."
if ! command -v java &> /dev/null; then
    echo "Установка OpenJDK 11..."
    sudo apt install -y openjdk-11-jdk
else
    echo "JDK уже установлен: $(java -version 2>&1 | head -n 1)"
fi

echo "Проверка установки Maven..."
if ! command -v mvn &> /dev/null; then
    echo "Установка Maven..."
    sudo apt install -y maven
else
    echo "Maven уже установлен: $(mvn -version | head -n 1)"
fi

echo "Проверка установки Node.js..."
if ! command -v node &> /dev/null; then
    echo "Установка Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "Node.js уже установлен: $(node --version)"
fi

echo "Проверка установки Appium..."
if ! command -v appium &> /dev/null; then
    echo "Установка Appium..."
    sudo npm install -g appium
    echo "Установка драйвера UiAutomator2..."
    appium driver install uiautomator2
else
    echo "Appium уже установлен: $(appium --version)"
fi

echo "Проверка установки Android SDK..."
if [ -z "$ANDROID_HOME" ]; then
    echo "ANDROID_HOME не установлен."
    echo "Для установки Android SDK рекомендуется использовать Android Studio"
else
    echo "ANDROID_HOME установлен: $ANDROID_HOME"
fi

echo "Проверка установки adb..."
if ! command -v adb &> /dev/null; then
    echo "Установка adb..."
    sudo apt install -y android-tools-adb android-tools-fastboot
else
    echo "adb уже установлен: $(adb version | head -n 1)"
fi

echo "Установка зависимостей Maven проекта..."
if [ -f "pom.xml" ]; then
    mvn clean install -DskipTests
    echo "Зависимости Maven установлены"
else
    echo "Предупреждение: pom.xml не найден"
fi

echo ""
echo "Установка завершена"
echo ""
