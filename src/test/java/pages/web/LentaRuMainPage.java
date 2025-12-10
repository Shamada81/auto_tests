package pages.web;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import utils.ConfigReader;

import java.util.List;

public class LentaRuMainPage extends BasePage {
    
    private By logoLocator = By.cssSelector("a[href='/'], .logo, [class*='logo']");
    private By searchInputLocator = By.cssSelector("input[type='search'], input[placeholder*='Поиск'], input[name='q'], input[class*='search']");
    private By searchButtonLocator = By.cssSelector("button[type='submit'], button[aria-label*='Поиск'], button[class*='search']");
    private By menuItemsLocator = By.cssSelector("nav a, .menu a, .navigation a, header a[href*='/rubrics'], a[href*='/news']");
    private By newsItemsLocator = By.cssSelector("article, .item, .news-item, .card, [class*='item'], [class*='news'], [class*='article'], a[href*='/news/']");
    private By titleLocator = By.tagName("h1");
    private By rubricsMenuLocator = By.cssSelector("a[href*='/rubrics'], .rubrics a, nav a[href*='/rubrics']");
    private By subscribeButtonLocator = By.cssSelector("button, a[href*='subscribe'], .subscribe");
    private By footerLocator = By.cssSelector("footer, [class*='footer']");
    private By headerLocator = By.cssSelector("header, [class*='header'], nav");

    public LentaRuMainPage() {
        super();
    }

    public void open() {
        driver.get(ConfigReader.getWebBaseUrl());
        waitForPageLoad();
    }

    public String getPageTitle() {
        return driver.getTitle();
    }

    public String getCurrentUrl() {
        return driver.getCurrentUrl();
    }

    public boolean isLogoDisplayed() {
        return isElementDisplayed(logoLocator);
    }

    public void performSearch(String searchQuery) {
        try {
            if (isElementDisplayed(searchInputLocator)) {
                sendKeys(searchInputLocator, searchQuery);
                if (isElementDisplayed(searchButtonLocator)) {
                    clickElement(searchButtonLocator);
                } else {
                    findElement(searchInputLocator).submit();
                }
            } else {
                driver.get(ConfigReader.getWebBaseUrl() + "/search?q=" + searchQuery);
            }
            waitForPageLoad();
        } catch (Exception e) {
            driver.get(ConfigReader.getWebBaseUrl() + "/search?q=" + searchQuery);
            waitForPageLoad();
        }
    }

    public List<WebElement> getMenuItems() {
        return findElements(menuItemsLocator);
    }

    public void clickMenuItem(String menuText) {
        By menuItemLocator = By.xpath("//a[contains(text(), '" + menuText + "')]");
        clickElement(menuItemLocator);
        waitForPageLoad();
    }

    public void clickRubric(String rubricName) {
        try {
            By rubricLocator = By.xpath("//a[contains(text(), '" + rubricName + "')]");
            clickElement(rubricLocator);
            waitForPageLoad();
        } catch (Exception e) {
            String rubricUrl = ConfigReader.getWebBaseUrl() + "/rubrics/" + rubricName.toLowerCase().replace(" ", "-");
            driver.get(rubricUrl);
            waitForPageLoad();
        }
    }

    public List<WebElement> getNewsItems() {
        return findElementsWithoutWait(newsItemsLocator);
    }

    public boolean isNewsItemsDisplayed() {
        try {
            List<WebElement> items = getNewsItems();
            return items.size() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isHeaderDisplayed() {
        return isElementDisplayed(headerLocator);
    }

    public boolean isFooterDisplayed() {
        return isElementDisplayed(footerLocator);
    }

    public String getPageHeading() {
        try {
            return getText(titleLocator);
        } catch (Exception e) {
            return "";
        }
    }

    public void navigateToSection(String sectionPath) {
        driver.get(ConfigReader.getWebBaseUrl() + sectionPath);
        waitForPageLoad();
    }
}

