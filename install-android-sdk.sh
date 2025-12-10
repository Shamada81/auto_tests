#!/bin/bash

set -e

echo "Установка Android SDK"
echo ""

echo "1. Создание директории..."
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk
echo "   Директория создана: ~/Android/Sdk"
echo ""

echo "2. Скачивание Android Command Line Tools..."
if [ ! -f "commandlinetools-linux.zip" ]; then
    echo "   Скачивание..."
    wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools-linux.zip
    echo "   Скачано"
else
    echo "   Файл уже скачан"
fi
echo ""

echo "3. Распаковка Command Line Tools..."
if [ ! -d "cmdline-tools/latest" ]; then
    echo "   Распаковка..."
    unzip -q commandlinetools-linux.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    echo "   Распаковано"
else
    echo "   Уже распаковано"
fi
echo ""

echo "4. Настройка переменных окружения..."
if ! grep -q "ANDROID_HOME" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Android SDK" >> ~/.bashrc
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.bashrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> ~/.bashrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/emulator" >> ~/.bashrc
    echo "   Добавлено в ~/.bashrc"
else
    echo "   Уже настроено в ~/.bashrc"
fi
echo ""

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

echo "5. Проверка sdkmanager..."
if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "   sdkmanager найден"
    echo "   Версия: $($ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --version 2>&1 | head -1)"
else
    echo "   sdkmanager не найден"
    exit 1
fi
echo ""

echo "6. Установка компонентов Android SDK..."
echo "   Это может занять 10-15 минут..."
echo ""

yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1 || true

$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.0" \
    "emulator" \
    "system-images;android-33;google_apis;x86_64" \
    2>&1 | tail -5

echo ""
echo "   Компоненты установлены"
echo ""

echo "7. Создание виртуального устройства..."
if [ -f "$ANDROID_HOME/emulator/emulator" ]; then
    echo "   Создание AVD 'test_emulator'..."
    echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
        -n test_emulator \
        -k "system-images;android-33;google_apis;x86_64" \
        -d "pixel_5" 2>&1 | tail -3 || echo "   (AVD может быть уже создан)"
    echo "   Эмулятор создан"
else
    echo "   Эмулятор не установлен"
fi
echo ""

echo "Установка завершена"
echo ""
echo "Перезагрузите терминал или выполните: source ~/.bashrc"
echo ""
