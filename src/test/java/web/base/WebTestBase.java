package web.base;

import config.TestConfig;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;

import java.time.Duration;

/**
 * Базовый класс для веб-тестов.
 * Отвечает за инициализацию и закрытие WebDriver.
 */
public abstract class WebTestBase {

    protected WebDriver driver;
    protected WebDriverWait wait;

    @BeforeClass(alwaysRun = true)
    public void setUpWebDriver() {
        String browser = TestConfig.getWebBrowser().toLowerCase();

        switch (browser) {
            case "firefox":
                WebDriverManager.firefoxdriver().setup();
                driver = new FirefoxDriver();
                break;
            case "edge":
                WebDriverManager.edgedriver().setup();
                driver = new EdgeDriver();
                break;
            case "chrome":
            default:
                WebDriverManager.chromedriver().setup();
                driver = new ChromeDriver();
                break;
        }

        driver.manage().window().maximize();
        // Устанавливаем таймауты для предотвращения зависаний
        driver.manage().timeouts().pageLoadTimeout(60, java.util.concurrent.TimeUnit.SECONDS);
        driver.manage().timeouts().setScriptTimeout(30, java.util.concurrent.TimeUnit.SECONDS);
        driver.manage().timeouts().implicitlyWait(TestConfig.getImplicitWaitSeconds(), java.util.concurrent.TimeUnit.SECONDS);
        wait = new WebDriverWait(driver, TestConfig.getExplicitWaitSeconds());
        // Не открываем страницу в setUp - каждый тест сам открывает нужную страницу
    }

    @AfterClass(alwaysRun = true)
    public void tearDownWebDriver() {
        if (driver != null) {
            driver.quit();
        }
    }
}


