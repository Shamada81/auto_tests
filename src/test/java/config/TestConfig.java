package config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Утилитный класс для чтения настроек из config.properties
 * и/или переменных окружения (для кроссплатформенности).
 */
public class TestConfig {

    private static final Properties PROPERTIES = new Properties();

    static {
        try (InputStream is = TestConfig.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (is != null) {
                PROPERTIES.load(is);
            } else {
                throw new IllegalStateException("Не найден файл config.properties в classpath");
            }
        } catch (IOException e) {
            throw new RuntimeException("Ошибка чтения config.properties", e);
        }
    }

    private static String getEnvOrProperty(String envName, String propertyKey) {
        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }
        return PROPERTIES.getProperty(propertyKey);
    }

    public static String getWebBaseUrl() {
        return getEnvOrProperty("WEB_BASE_URL", "web.baseUrl");
    }

    public static String getWebBrowser() {
        return getEnvOrProperty("WEB_BROWSER", "web.browser");
    }

    public static String getMobilePlatformName() {
        return getEnvOrProperty("MOBILE_PLATFORM_NAME", "mobile.platformName");
    }

    public static String getMobileDeviceName() {
        return getEnvOrProperty("MOBILE_DEVICE_NAME", "mobile.deviceName");
    }

    public static String getMobileAutomationName() {
        return getEnvOrProperty("MOBILE_AUTOMATION_NAME", "mobile.automationName");
    }

    public static String getMobileAppPackage() {
        return getEnvOrProperty("MOBILE_APP_PACKAGE", "mobile.appPackage");
    }

    public static String getMobileAppActivity() {
        return getEnvOrProperty("MOBILE_APP_ACTIVITY", "mobile.appActivity");
    }

    public static String getMobileAppiumServerUrl() {
        return getEnvOrProperty("APPIUM_SERVER_URL", "mobile.appiumServerUrl");
    }

    public static int getImplicitWaitSeconds() {
        return Integer.parseInt(PROPERTIES.getProperty("implicit.wait.seconds", "5"));
    }

    public static int getExplicitWaitSeconds() {
        return Integer.parseInt(PROPERTIES.getProperty("explicit.wait.seconds", "15"));
    }
}


