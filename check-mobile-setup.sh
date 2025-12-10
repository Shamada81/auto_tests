#!/bin/bash

echo "Проверка мобильного окружения"
echo ""

echo "1. Проверка Appium..."
if command -v appium &> /dev/null; then
    echo "   Appium установлен: $(appium --version 2>&1 | head -1)"
    
    if appium driver list 2>/dev/null | grep -q "uiautomator2"; then
        echo "   Драйвер UiAutomator2 установлен"
    else
        echo "   Драйвер UiAutomator2 не найден"
    fi
else
    echo "   Appium не установлен"
fi
echo ""

echo "2. Проверка adb..."
if command -v adb &> /dev/null; then
    echo "   adb установлен"
else
    echo "   adb не установлен"
fi
echo ""

echo "3. Проверка подключенных устройств..."
if command -v adb &> /dev/null; then
    devices=$(adb devices 2>/dev/null | grep -v "List" | grep "device" | wc -l)
    if [ "$devices" -gt 0 ]; then
        echo "   Найдено устройств: $devices"
        adb devices 2>/dev/null | grep "device"
    else
        echo "   Устройства не найдены"
    fi
else
    echo "   adb не установлен"
fi
echo ""

echo "4. Проверка Android SDK..."
if [ -n "$ANDROID_HOME" ]; then
    echo "   ANDROID_HOME установлен: $ANDROID_HOME"
    
    if [ -d "$ANDROID_HOME/platform-tools" ]; then
        echo "   Platform-tools найдены"
    fi
    
    if [ -d "$ANDROID_HOME/emulator" ]; then
        echo "   Emulator найден"
        
        if command -v emulator &> /dev/null; then
            avds=$(emulator -list-avds 2>/dev/null | wc -l)
            if [ "$avds" -gt 0 ]; then
                echo "   Найдено эмуляторов: $avds"
                emulator -list-avds 2>/dev/null
            else
                echo "   Эмуляторы не найдены"
            fi
        fi
    fi
else
    echo "   ANDROID_HOME не установлен"
fi
echo ""

echo "5. Проверка Wikipedia APK..."
if command -v adb &> /dev/null; then
    if adb devices 2>/dev/null | grep -q "device"; then
        if adb shell pm list packages 2>/dev/null | grep -q "org.wikipedia"; then
            echo "   Wikipedia установлена"
        else
            echo "   Wikipedia не установлена"
        fi
    else
        echo "   Устройство не подключено"
    fi
else
    echo "   adb не установлен"
fi
echo ""

echo "6. Проверка Appium Server..."
if curl -s http://localhost:4723/wd/hub/status > /dev/null 2>&1; then
    echo "   Appium Server запущен"
else
    echo "   Appium Server не запущен"
fi
echo ""

echo "7. Проверка конфигурации..."
if [ -f "src/test/resources/config.properties" ]; then
    echo "   config.properties найден"
    
    if grep -q "android.device.name" src/test/resources/config.properties; then
        device_name=$(grep "android.device.name" src/test/resources/config.properties | cut -d'=' -f2)
        echo "   android.device.name: $device_name"
    fi
else
    echo "   config.properties не найден"
fi
echo ""

echo "Проверка завершена"
echo ""
