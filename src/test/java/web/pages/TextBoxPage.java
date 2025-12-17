package web.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Страница Text Box в разделе Elements.
 */
public class TextBoxPage {

    private final WebDriver driver;
    private final WebDriverWait wait;

    private final By fullNameInput = By.id("userName");
    private final By emailInput = By.id("userEmail");
    private final By currentAddressInput = By.id("currentAddress");
    private final By permanentAddressInput = By.id("permanentAddress");
    private final By submitButton = By.id("submit");

    private final By outputBox = By.id("output");

    public TextBoxPage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, 10);
    }

    public void fillForm(String name, String email, String currentAddress, String permanentAddress) {
        wait.until(ExpectedConditions.presenceOfElementLocated(fullNameInput));
        driver.findElement(fullNameInput).clear();
        driver.findElement(fullNameInput).sendKeys(name);

        wait.until(ExpectedConditions.presenceOfElementLocated(emailInput));
        driver.findElement(emailInput).clear();
        driver.findElement(emailInput).sendKeys(email);

        wait.until(ExpectedConditions.presenceOfElementLocated(currentAddressInput));
        driver.findElement(currentAddressInput).clear();
        driver.findElement(currentAddressInput).sendKeys(currentAddress);

        wait.until(ExpectedConditions.presenceOfElementLocated(permanentAddressInput));
        driver.findElement(permanentAddressInput).clear();
        driver.findElement(permanentAddressInput).sendKeys(permanentAddress);
    }

    public void submit() {
        wait.until(ExpectedConditions.elementToBeClickable(submitButton));
        driver.findElement(submitButton).click();
    }

    public String getOutputText() {
        wait.until(ExpectedConditions.presenceOfElementLocated(outputBox));
        return driver.findElement(outputBox).getText();
    }
}


