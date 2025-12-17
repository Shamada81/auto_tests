package web.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Страница Check Box в разделе Elements.
 */
public class CheckBoxPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private final By expandAllButton = By.cssSelector(".rct-option-expand-all");
    private final By homeCheckbox = By.cssSelector("span.rct-title");
    private final By resultPanel = By.id("result");

    public CheckBoxPage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, 10);
    }

    public void expandAll() {
        wait.until(ExpectedConditions.elementToBeClickable(expandAllButton));
        driver.findElement(expandAllButton).click();
    }

    public void selectHome() {
        wait.until(ExpectedConditions.presenceOfElementLocated(homeCheckbox));
        WebElement home = driver.findElement(homeCheckbox);
        home.click();
    }

    public String getResultText() {
        wait.until(ExpectedConditions.presenceOfElementLocated(resultPanel));
        return driver.findElement(resultPanel).getText();
    }
}


