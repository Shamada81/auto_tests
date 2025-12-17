package web.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Раздел Elements на demoqa.com
 */
public class ElementsPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private final By header = By.className("main-header");
    private final By textBoxMenuItem = By.id("item-0");
    private final By checkBoxMenuItem = By.id("item-1");

    public ElementsPage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, 10);
    }

    public String getHeaderText() {
        wait.until(ExpectedConditions.presenceOfElementLocated(header));
        return driver.findElement(header).getText();
    }

    public void openTextBox() {
        wait.until(ExpectedConditions.elementToBeClickable(textBoxMenuItem));
        WebElement item = driver.findElement(textBoxMenuItem);
        item.click();
    }

    public void openCheckBox() {
        wait.until(ExpectedConditions.elementToBeClickable(checkBoxMenuItem));
        WebElement item = driver.findElement(checkBoxMenuItem);
        item.click();
    }
}


