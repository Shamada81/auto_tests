package utils;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;

public class AppiumDriverManager {
    private static AndroidDriver driver;

    public static AndroidDriver getDriver() {
        if (driver == null) {
            UiAutomator2Options options = new UiAutomator2Options();
            options.setPlatformName("Android");
            options.setPlatformVersion(ConfigReader.getAndroidPlatformVersion());
            options.setDeviceName(ConfigReader.getAndroidDeviceName());
            options.setAppPackage(ConfigReader.getWikipediaAppPackage());
            String appActivity = ConfigReader.getWikipediaAppActivity();
            if (appActivity != null && !appActivity.isEmpty()) {
                options.setAppActivity(appActivity);
            }
            options.setAutomationName("UiAutomator2");
            options.setNoReset(true);
            options.setFullReset(false);
            options.setNewCommandTimeout(Duration.ofSeconds(60));

            try {
                URL appiumServerUrl = new URL(ConfigReader.getAppiumServerUrl());
                driver = new AndroidDriver(appiumServerUrl, options);
                driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));
            } catch (MalformedURLException e) {
                throw new RuntimeException("Неверный URL сервера Appium: " + ConfigReader.getAppiumServerUrl(), e);
            }
        }
        return driver;
    }

    public static void quitDriver() {
        if (driver != null) {
            driver.quit();
            driver = null;
        }
    }
}

