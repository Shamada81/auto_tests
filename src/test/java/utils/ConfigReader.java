package utils;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class ConfigReader {
    private static Properties properties;
    private static final String CONFIG_PATH = "src/test/resources/config.properties";

    static {
        properties = new Properties();
        try {
            FileInputStream fileInputStream = new FileInputStream(CONFIG_PATH);
            properties.load(fileInputStream);
            fileInputStream.close();
        } catch (IOException e) {
            throw new RuntimeException("Не удалось загрузить файл конфигурации: " + CONFIG_PATH, e);
        }
    }

    public static String getProperty(String key) {
        return properties.getProperty(key);
    }

    public static String getWebBaseUrl() {
        return getProperty("web.base.url");
    }

    public static String getWebBrowser() {
        return getProperty("web.browser");
    }

    public static int getWebTimeout() {
        return Integer.parseInt(getProperty("web.timeout"));
    }

    public static String getAppiumServerUrl() {
        return getProperty("appium.server.url");
    }

    public static String getAndroidPlatformVersion() {
        return getProperty("android.platform.version");
    }

    public static String getAndroidDeviceName() {
        return getProperty("android.device.name");
    }

    public static String getWikipediaAppPackage() {
        return getProperty("wikipedia.app.package");
    }

    public static String getWikipediaAppActivity() {
        return getProperty("wikipedia.app.activity");
    }
}

