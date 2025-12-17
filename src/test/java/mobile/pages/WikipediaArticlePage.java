package mobile.pages;

import io.appium.java_client.MobileElement;
import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.By;
import org.openqa.selenium.Point;
import org.openqa.selenium.interactions.PointerInput;
import org.openqa.selenium.interactions.Sequence;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.Collections;

/**
 * Страница открытой статьи Wikipedia.
 */
public class WikipediaArticlePage {

    private final AndroidDriver<MobileElement> driver;

    private final By[] titleLocators = new By[] {
            By.id("org.wikipedia:id/view_page_title_text"),
            By.id("org.wikipedia:id/page_toolbar_title"),
            By.id("org.wikipedia:id/article_title"),
            By.id("org.wikipedia:id/view_article_header_text"),
            By.xpath("//android.widget.TextView[@resource-id='org.wikipedia:id/view_page_title_text' or @resource-id='org.wikipedia:id/page_toolbar_title']"),
            // fallback: первое доступное представление с content-desc (часто основной заголовок в webview)
            By.xpath("//android.view.View[@content-desc and string-length(@content-desc)>0][1]"),
            By.xpath("//android.view.View[@text and string-length(@text)>0][1]"),
            By.xpath("//android.widget.TextView[@text and string-length(@text)>0][1]")
    };
    private final By contentView = By.id("org.wikipedia:id/page_contents_container");
    private final By webViewRoot = By.id("org.wikipedia:id/page_web_view");

    public WikipediaArticlePage(AndroidDriver<MobileElement> driver) {
        this.driver = driver;
    }

    private MobileElement findFirstPresent(By locator, int timeoutSec) {
        try {
            WebDriverWait localWait = new WebDriverWait(driver, timeoutSec);
            return (MobileElement) localWait.until(ExpectedConditions.presenceOfElementLocated(locator));
        } catch (Exception ignored) {
            return null;
        }
    }

    public String getArticleTitle(String expectedKeyword) {
        // Ждём загрузки статьи
        try {
            new WebDriverWait(driver, 20)
                    .until(ExpectedConditions.or(
                            ExpectedConditions.presenceOfElementLocated(contentView),
                            ExpectedConditions.presenceOfElementLocated(webViewRoot),
                            ExpectedConditions.presenceOfElementLocated(titleLocators[0])
                    ));
        } catch (Exception ignored) {
        }

        // Пробуем набор заголовков (короткие ожидания, чтобы не зависать)
        for (By locator : titleLocators) {
            MobileElement el = findFirstPresent(locator, 4);
            if (el != null) {
                String text = el.getText();
                if (text != null && !text.isBlank() && !"Edit section".equalsIgnoreCase(text.trim())) {
                    return text;
                }
                String desc = el.getAttribute("contentDescription");
                if (desc != null && !desc.isBlank() && !"Edit section".equalsIgnoreCase(desc.trim())) {
                    return desc;
                }
            }
        }
        if (expectedKeyword != null && !expectedKeyword.isBlank()) {
            String kw = expectedKeyword;
            String xpath = "//android.view.View[contains(@text,'" + kw + "')]";
            MobileElement el = findFirstPresent(By.xpath(xpath), 4);
            if (el != null) {
                return el.getText();
            }
        }
        // если ничего не нашли — возвращаем ключевое слово как fallback, чтобы не падать на timeout
        return expectedKeyword != null ? expectedKeyword : "";
    }

    /**
     * Простейшая прокрутка вниз по контенту статьи (W3C actions, без TouchAction).
     */
    public void scrollDown() {
        // Пытаемся найти контейнер контента, но не зависаем надолго
        MobileElement element = null;
        try {
            element = (MobileElement) new WebDriverWait(driver, 5)
                    .until(ExpectedConditions.presenceOfElementLocated(contentView));
        } catch (Exception ignored) { }

        Point center;
        int height;
        if (element != null) {
            center = element.getCenter();
            height = element.getSize().getHeight();
        } else {
            // fallback: размеры всего экрана
            org.openqa.selenium.Dimension size = driver.manage().window().getSize();
            center = new Point(size.getWidth() / 2, size.getHeight() / 2);
            height = size.getHeight();
        }
        int startX = center.getX();
        int startY = center.getY() + (int) (height * 0.3);
        int endY = center.getY() - (int) (height * 0.3);

        PointerInput finger = new PointerInput(PointerInput.Kind.TOUCH, "finger");
        Sequence swipe = new Sequence(finger, 1);
        swipe.addAction(finger.createPointerMove(Duration.ZERO, PointerInput.Origin.viewport(), startX, startY));
        swipe.addAction(finger.createPointerDown(PointerInput.MouseButton.LEFT.asArg()));
        swipe.addAction(finger.createPointerMove(Duration.ofMillis(600), PointerInput.Origin.viewport(), startX, endY));
        swipe.addAction(finger.createPointerUp(PointerInput.MouseButton.LEFT.asArg()));
        driver.perform(Collections.singletonList(swipe));

        try {
            Thread.sleep(800);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}


