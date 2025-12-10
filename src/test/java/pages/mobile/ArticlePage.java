package pages.mobile;

import io.appium.java_client.AppiumBy;
import org.openqa.selenium.By;

public class ArticlePage extends BaseMobilePage {
    
    private By articleTitleLocator = AppiumBy.id("org.wikipedia:id/view_page_title_text");
    private By articleContentLocator = AppiumBy.id("org.wikipedia:id/page_contents_container");
    private By articleHeaderLocator = AppiumBy.id("org.wikipedia:id/view_page_header_container");
    private By tableOfContentsLocator = AppiumBy.id("org.wikipedia:id/page_toc");
    private By readMoreButtonLocator = AppiumBy.id("org.wikipedia:id/view_card_list_recycler");
    private By backButtonLocator = AppiumBy.accessibilityId("Navigate up");
    private By saveButtonLocator = AppiumBy.id("org.wikipedia:id/page_save");
    private By shareButtonLocator = AppiumBy.id("org.wikipedia:id/page_share");

    public ArticlePage() {
        super();
    }

    public String getArticleTitle() {
        try {
            return getText(articleTitleLocator);
        } catch (Exception e) {
            try {
                By altTitleLocator = AppiumBy.xpath("//android.widget.TextView[@resource-id='org.wikipedia:id/view_page_title_text']");
                return getText(altTitleLocator);
            } catch (Exception ex) {
                return "";
            }
        }
    }

    public boolean isArticleContentDisplayed() {
        return isElementDisplayed(articleContentLocator);
    }

    public boolean isArticleHeaderDisplayed() {
        return isElementDisplayed(articleHeaderLocator);
    }

    public void scrollDownInArticle() {
        scrollDown();
    }

    public void clickBackButton() {
        if (isElementDisplayed(backButtonLocator)) {
            clickElement(backButtonLocator);
        } else {
            driver.navigate().back();
        }
    }

    public boolean isTableOfContentsDisplayed() {
        return isElementDisplayed(tableOfContentsLocator);
    }

    public void scrollToElementInArticle(By locator) {
        int maxScrolls = 5;
        int scrollCount = 0;
        while (!isElementDisplayed(locator) && scrollCount < maxScrolls) {
            scrollDown();
            scrollCount++;
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
}

