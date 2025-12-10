package pages.web;

import org.openqa.selenium.By;

public class ArticlePage extends BasePage {
    
    private By articleTitleLocator = By.cssSelector("h1, .article-title, .title");
    private By articleContentLocator = By.cssSelector("article, .article-content, .content, .text");
    private By articleDateLocator = By.cssSelector(".date, .published, time");
    private By articleAuthorLocator = By.cssSelector(".author, .byline");

    public ArticlePage() {
        super();
    }

    public String getArticleTitle() {
        try {
            return getText(articleTitleLocator);
        } catch (Exception e) {
            return "";
        }
    }

    public boolean isArticleContentDisplayed() {
        return isElementDisplayed(articleContentLocator);
    }

    public String getArticleDate() {
        try {
            return getText(articleDateLocator);
        } catch (Exception e) {
            return "";
        }
    }

    public boolean isArticleAuthorDisplayed() {
        return isElementDisplayed(articleAuthorLocator);
    }
}

