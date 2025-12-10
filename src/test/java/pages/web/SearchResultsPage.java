package pages.web;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import java.util.List;

public class SearchResultsPage extends BasePage {
    
    private By searchResultsLocator = By.cssSelector("article, .item, .news-item, .search-result, .card");
    private By searchQueryLocator = By.cssSelector("input[type='search'], input[value]");
    private By noResultsMessageLocator = By.cssSelector(".no-results, .empty, .not-found");

    public SearchResultsPage() {
        super();
    }

    public List<WebElement> getSearchResults() {
        return findElements(searchResultsLocator);
    }

    public int getSearchResultsCount() {
        return getSearchResults().size();
    }

    public boolean hasSearchResults() {
        return getSearchResultsCount() > 0;
    }

    public String getSearchQuery() {
        try {
            WebElement searchInput = findElement(searchQueryLocator);
            return searchInput.getAttribute("value");
        } catch (Exception e) {
            return "";
        }
    }

    public boolean isNoResultsMessageDisplayed() {
        return isElementDisplayed(noResultsMessageLocator);
    }

    public void clickFirstResult() {
        List<WebElement> results = getSearchResults();
        if (!results.isEmpty()) {
            results.get(0).click();
            waitForPageLoad();
        }
    }
}

