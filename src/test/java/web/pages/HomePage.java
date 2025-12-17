package web.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Главная страница demoqa.com
 */
public class HomePage {

    private final WebDriver driver;

    private final By elementsCard = By.xpath("//h5[text()='Elements']/ancestor::div[contains(@class,'top-card')]");
    private final By formsCard = By.xpath("//h5[text()='Forms']/ancestor::div[contains(@class,'top-card')]");

    public HomePage(WebDriver driver) {
        this.driver = driver;
    }

    public void openElements() {
        try {
            WebElement card = new WebDriverWait(driver, 10)
                    .until(ExpectedConditions.elementToBeClickable(elementsCard));
            card.click();
        } catch (org.openqa.selenium.TimeoutException e) {
            // Если элемент не найден, переходим по прямой ссылке
            driver.navigate().to("https://demoqa.com/elements");
        }
    }

    public void openForms() {
        try {
            WebElement card = new WebDriverWait(driver, 10)
                    .until(ExpectedConditions.elementToBeClickable(formsCard));
            card.click();
        } catch (org.openqa.selenium.TimeoutException e) {
            // Если элемент не найден, переходим по прямой ссылке
            driver.navigate().to("https://demoqa.com/forms");
        }
    }
}


