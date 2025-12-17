package mobile.base;

import config.TestConfig;
import io.appium.java_client.MobileElement;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.Activity;
import io.appium.java_client.remote.MobileCapabilityType;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * Базовый класс для мобильных тестов (Wikipedia).
 * Инициализирует AndroidDriver с использованием Appium.
 */
public abstract class MobileTestBase {

    protected AndroidDriver<MobileElement> driver;
    protected WebDriverWait wait;

    /**
     * Находит APK файл Wikipedia в проекте.
     * Проверяет корень проекта и директорию scripts.
     */
    private String findWikipediaApk() {
        // Получаем текущую рабочую директорию (обычно это корень проекта)
        String projectRoot = System.getProperty("user.dir");
        
        // Возможные пути к APK
        String[] possiblePaths = {
            projectRoot + File.separator + "wikipedia.apk",
            projectRoot + File.separator + "scripts" + File.separator + "wikipedia.apk",
            "wikipedia.apk",
            "scripts" + File.separator + "wikipedia.apk"
        };
        
        for (String path : possiblePaths) {
            File apkFile = new File(path);
            if (apkFile.exists() && apkFile.isFile()) {
                System.out.println("Найден APK файл: " + apkFile.getAbsolutePath());
                return apkFile.getAbsolutePath();
            }
        }
        
        return null;
    }

    @BeforeClass(alwaysRun = true)
    public void setUpMobileDriver() throws MalformedURLException {
        DesiredCapabilities caps = new DesiredCapabilities();
        caps.setCapability(MobileCapabilityType.PLATFORM_NAME, TestConfig.getMobilePlatformName());
        caps.setCapability(MobileCapabilityType.DEVICE_NAME, TestConfig.getMobileDeviceName());
        caps.setCapability(MobileCapabilityType.AUTOMATION_NAME, TestConfig.getMobileAutomationName());
        caps.setCapability(MobileCapabilityType.NEW_COMMAND_TIMEOUT, 300);
        caps.setCapability("unicodeKeyboard", false);
        caps.setCapability("resetKeyboard", false);
        caps.setCapability("autoGrantPermissions", true);
        // Appium 2.x требует префикс appium: для нестандартных capability
        caps.setCapability("appium:adbExecTimeout", 120000);
        caps.setCapability("appium:uiautomator2ServerInstallTimeout", 120000);
        caps.setCapability("appium:uiautomator2ServerLaunchTimeout", 120000);
        caps.setCapability("appium:settingsAppInstallTimeout", 120000);
        caps.setCapability("appium:disableWindowAnimation", true);
        caps.setCapability("appium:ignoreHiddenApiPolicyError", true);
        // Дольше ждём готовность устройства к запуску сессии
        caps.setCapability("appium:deviceReadyTimeout", 60);
        caps.setCapability("appium:androidDeviceReadyTimeout", 60);
        
        // Получаем appPackage и appActivity из конфигурации
        String appPackage = TestConfig.getMobileAppPackage();
        String appActivity = TestConfig.getMobileAppActivity();
        
        // Исправляем Activity - используем полный путь
        if (appActivity != null && appActivity.startsWith(".")) {
            // Относительный путь - преобразуем в полный
            appActivity = appPackage + appActivity;
            System.out.println("Activity преобразован в полный путь: " + appActivity);
        } else if (appActivity == null || appActivity.isEmpty()) {
            // Если Activity не указан, используем стандартный
            appActivity = appPackage + ".main.MainActivity";
            System.out.println("Activity не указан, используется стандартный: " + appActivity);
        }
        
        // ВСЕГДА указываем appPackage и appActivity явно (даже с APK файлом!)
        // Это необходимо, чтобы избежать ошибки "Intent matches multiple activities"
        caps.setCapability("appPackage", appPackage);
        caps.setCapability("appActivity", appActivity);
        caps.setCapability("appium:appWaitActivity", "org.wikipedia.*");
        caps.setCapability("appium:appWaitForLaunch", true);
        
        // Пытаемся найти APK файл
        String apkPath = findWikipediaApk();
        if (apkPath != null) {
            // Если APK найден - используем его для установки
            caps.setCapability(MobileCapabilityType.APP, apkPath);
            // Оставляем данные приложения между прогонами, чтобы не видеть онбординг каждый раз
            caps.setCapability("appium:noReset", true);
            caps.setCapability("appium:fullReset", false);
            System.out.println("Используется APK файл для установки приложения: " + apkPath);
            System.out.println("Будет запущена активность: " + appPackage + "/" + appActivity);
        } else {
            // Если APK не найден - используем установленное приложение
            caps.setCapability("appium:noReset", true);
            caps.setCapability("appium:fullReset", false);
            System.out.println("APK файл не найден. Используется установленное приложение: " + appPackage + "/" + appActivity);
        }

        String appiumUrl = TestConfig.getMobileAppiumServerUrl();
        System.out.println("Подключение к Appium серверу: " + appiumUrl);
        
        try {
            // Явно ждём устройство перед созданием сессии
            Runtime.getRuntime().exec(new String[]{"adb", "wait-for-device"}).waitFor();
            Runtime.getRuntime().exec(new String[]{"adb", "shell", "wm", "dismiss-keyguard"}).waitFor();
            Runtime.getRuntime().exec(new String[]{"adb", "shell", "input", "keyevent", "82"}).waitFor();

            URL appiumServer = java.net.URI.create(appiumUrl).toURL();
            driver = new AndroidDriver<>(appiumServer, caps);
            driver.manage().timeouts().implicitlyWait(TestConfig.getImplicitWaitSeconds(), java.util.concurrent.TimeUnit.SECONDS);
            wait = new WebDriverWait(driver, TestConfig.getExplicitWaitSeconds());
            // Явно активируем основную активность Wikipedia на случай, если приложение не вывелось на передний план
            try {
                driver.startActivity(new Activity(appPackage, appActivity));
            } catch (Exception ignored) {
                // если уже запущено или активность недоступна, продолжаем
            }
            System.out.println("Успешно подключено к устройству Android");
        } catch (org.openqa.selenium.SessionNotCreatedException e) {
            throw new RuntimeException("Не удалось создать сессию Appium. " +
                    "Убедитесь, что:\n" +
                    "1. Appium сервер запущен\n" +
                    "2. Android устройство/эмулятор подключено (проверьте: adb devices)\n" +
                    "3. Приложение Wikipedia установлено на устройстве\n" +
                    "Ошибка: " + e.getMessage(), e);
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            if (errorMsg != null && (errorMsg.contains("Connection refused") || 
                                     errorMsg.contains("connect") || 
                                     errorMsg.contains("ECONNREFUSED"))) {
                throw new RuntimeException("Не удалось подключиться к Appium серверу по адресу: " + appiumUrl + 
                        "\nУбедитесь, что Appium сервер запущен и доступен.\n" +
                        "Ошибка: " + errorMsg, e);
            } else {
                throw new RuntimeException("Ошибка при инициализации AndroidDriver: " + errorMsg, e);
            }
        }
    }

    @AfterClass(alwaysRun = true)
    public void tearDownMobileDriver() {
        if (driver != null) {
            driver.quit();
        }
    }
}


