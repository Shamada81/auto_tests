## UI автотесты: веб-сайт + Android Wikipedia

Учебный проект с автотестами для:

- **веб-сайта**: `https://demoqa.com` (Selenium + TestNG);
- **Android-приложения Wikipedia** (Appium + TestNG).

Стек: **Java 11**, **Maven**, **Selenium WebDriver**, **TestNG**, **Appium Java Client**, **WebDriverManager**.

---

### Структура проекта

- **`pom.xml`**: зависимости и плагины Maven.
- **`testng.xml`**: конфигурация запуска тестов (блоки `Web Tests` и `Mobile Tests`).
- **`src/test/resources/config.properties`**: базовые настройки (URL сайта, браузер, Appium capabilities и таймауты).
- **`src/test/java/config/TestConfig.java`**: чтение настроек из `config.properties` и переменных окружения.
- **`src/test/java/web`**:
  - `base/WebTestBase.java` — базовый класс для веб‑тестов (инициализация WebDriver).
  - `pages/*.java` — Page Object’ы для сайта `demoqa.com`.
  - `tests/DemoQaWebTests.java` — набор web‑тестов (минимум 4 сценария).
- **`src/test/java/mobile`**:
  - `base/MobileTestBase.java` — базовый класс для мобильных тестов (инициализация AndroidDriver через Appium).
  - `pages/*.java` — Page Object’ы для экранов Wikipedia.
  - `tests/WikipediaMobileTests.java` — набор мобильных тестов (минимум 3 сценария).
- **`scripts/`**:
  - `setup_web.sh` — подготовка окружения для веб‑тестов.
  - `run_web_tests.sh` — запуск веб‑тестов.
  - `setup_mobile.sh` — подготовка окружения для мобильных тестов.
  - `run_mobile_tests.sh` — запуск мобильных тестов (поднимает Appium‑сервер).

---

### Требуемое окружение

- **JDK**: версия **11+** (OpenJDK или Oracle JDK).
- **Maven**: 3.8+.
- **Браузер**: Chrome / Firefox / Edge (WebDriverManager сам скачает подходящий драйвер).
- **Для Android‑тестов**:
  - Android SDK / Android Studio;
  - настроенная переменная `ANDROID_HOME` и platform-tools в `PATH`;
  - установленный **Appium** (`npm install -g appium`) и `appium-doctor`;
  - Android‑эмулятор или реальное устройство;
  - установленное приложение **Wikipedia** (`org.wikipedia`).

---

### Настройки (config.properties и переменные окружения)

Базовые значения заданы в `src/test/resources/config.properties`. Их можно переопределить переменными окружения:

- **Веб**:
  - `WEB_BASE_URL` (по умолчанию `https://demoqa.com`);
  - `WEB_BROWSER` (`chrome`/`firefox`/`edge`, по умолчанию `chrome`).
- **Мобильные**:
  - `MOBILE_PLATFORM_NAME` (по умолчанию `Android`);
  - `MOBILE_DEVICE_NAME` (по умолчанию `Android Emulator`);
  - `MOBILE_APP_PACKAGE` (по умолчанию `org.wikipedia`);
  - `MOBILE_APP_ACTIVITY` (по умолчанию `org.wikipedia.main.MainActivity`);
  - `APPIUM_SERVER_URL` (по умолчанию `http://127.0.0.1:4723`).

Таймауты ожиданий управляются ключами `implicit.wait.seconds` и `explicit.wait.seconds` в `config.properties`.

---

### Установка и запуск веб‑тестов

1. **Клонируйте репозиторий** и перейдите в каталог проекта:

```bash
git clone <URL_ВАШЕГО_РЕПОЗИТОРИЯ>
cd ui-auto-tests
```

2. Убедитесь, что установлены JDK и Maven и доступны в `PATH`:

```bash
java -version
mvn -version
```

3. При необходимости настройте переменные окружения:

```bash
export WEB_BROWSER=chrome
export WEB_BASE_URL=https://demoqa.com
```

4. (Опционально) выполните скрипт подготовки окружения:

```bash
chmod +x scripts/setup_web.sh
./scripts/setup_web.sh
```

5. **Запуск веб‑тестов** (через скрипт):

```bash
chmod +x scripts/run_web_tests.sh
./scripts/run_web_tests.sh
```

Или напрямую Maven:

```bash
mvn test -Dsurefire.suiteXmlFiles=testng.xml
```

---

### Установка и запуск мобильных тестов (Wikipedia + Appium)

1. Установите **Node.js** и **npm** (способ зависит от ОС).
2. Установите Appium и appium‑doctor:

```bash
npm install -g appium appium-doctor
```

3. Проверьте окружение Android:

```bash
appium-doctor --android
```

4. Убедитесь, что:

- настроен Android‑эмулятор/устройство;
- установлено приложение Wikipedia (`org.wikipedia`);
- `adb devices` показывает подключённое устройство.

5. (Опционально) выполните скрипт подготовки окружения:

```bash
chmod +x scripts/setup_mobile.sh
./scripts/setup_mobile.sh
```

6. Настройте при необходимости переменные окружения:

```bash
export MOBILE_DEVICE_NAME="Android Emulator"
export MOBILE_PLATFORM_NAME="Android"
export MOBILE_APP_PACKAGE="org.wikipedia"
export MOBILE_APP_ACTIVITY="org.wikipedia.main.MainActivity"
export APPIUM_SERVER_URL="http://127.0.0.1:4723"
```

7. **Запуск мобильных тестов** (скрипт сам поднимет Appium‑сервер на порту 4723):

```bash
chmod +x scripts/run_mobile_tests.sh
./scripts/run_mobile_tests.sh
```

При необходимости можно изменить порт, передав `APPIUM_PORT`:

```bash
APPIUM_PORT=4725 ./scripts/run_mobile_tests.sh
```

---

### Что именно покрывают тесты

- **Web (DemoQA)**:
  - переход с главной страницы в раздел **Elements** и проверка заголовка;
  - переход в раздел **Forms** и проверка URL;
  - заполнение формы **Text Box** и проверка вывода введённых данных;
  - работа страницы **Check Box**: раскрытие дерева, выбор `Home`, проверка результата.

- **Mobile (Wikipedia)**:
  - поиск статьи по слову **«Appium»** и проверка, что заголовок статьи содержит `Appium`;
  - поиск статьи **«Selenium (software)»** и проверка точного заголовка;
  - открытие статьи **«Software testing»**, прокрутка вниз и проверка сохранения заголовка.

---

### Кроссплатформенность и независимость от путей

- Проект не использует жёстко прописанные абсолютные пути.
- Все настройки выносятся в `config.properties` и/или переменные окружения.
- WebDriverManager сам загружает нужные драйверы браузеров.
- Appium‑URL и параметры устройства задаются через конфиг/переменные, поэтому проект можно запускать на любом компьютере при наличии требуемых инструментов.





# auto_tests
