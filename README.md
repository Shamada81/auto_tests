# Автоматизированные тесты

Проект содержит автоматизированные тесты для веб-сайта lenta.ru и мобильного приложения Wikipedia на Android.

## Структура проекта

```
src/test/java/
├── pages/
│   ├── web/          # Page Object для веб-тестов
│   └── mobile/       # Page Object для мобильных тестов
├── tests/
│   ├── web/          # Веб-тесты
│   └── mobile/       # Мобильные тесты
└── utils/            # Утилиты
```

## Технологии

- Java 11+
- Maven
- Selenium WebDriver 4.15.0
- TestNG 7.8.0
- Appium Java Client 9.0.0
- WebDriverManager 5.6.2

## Требования

- JDK 11 или выше
- Maven 3.6+
- Для веб-тестов: браузер Chrome
- Для мобильных тестов: Android SDK, эмулятор, Appium

## Установка

```bash
mvn clean install
```

## Запуск тестов

### Веб-тесты

```bash
mvn clean test -Dtest=LentaRuWebTests
```

### Мобильные тесты

1. Запустите эмулятор Android
2. Установите Wikipedia APK на эмулятор
3. Запустите Appium Server: `appium`
4. Запустите тесты: `mvn clean test -Dtest=WikipediaMobileTests`

## Конфигурация

Настройки находятся в `src/test/resources/config.properties`

## Результаты тестов

Отчеты сохраняются в `target/surefire-reports/`
