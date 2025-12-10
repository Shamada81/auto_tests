package pages.mobile;

import io.appium.java_client.AppiumBy;
import org.openqa.selenium.By;

public class MainPage extends BaseMobilePage {
    
    private By searchContainerLocator = AppiumBy.id("org.wikipedia:id/search_container");
    private By searchEditTextLocator = AppiumBy.id("org.wikipedia:id/search_src_text");
    private By searchResultsLocator = AppiumBy.id("org.wikipedia:id/page_list_item_title");
    private By moreOptionsButtonLocator = AppiumBy.accessibilityId("More options");
    private By settingsButtonLocator = AppiumBy.id("org.wikipedia:id/main_drawer_settings_container");
    private By exploreTabLocator = AppiumBy.id("org.wikipedia:id/nav_tab_explore");
    private By savedTabLocator = AppiumBy.id("org.wikipedia:id/nav_tab_reading_lists");
    private By searchTabLocator = AppiumBy.id("org.wikipedia:id/nav_tab_search");
    private By historyTabLocator = AppiumBy.id("org.wikipedia:id/nav_tab_history");

    public MainPage() {
        super();
    }

    public void clickSearchContainer() {
        clickElement(searchContainerLocator);
    }

    public void enterSearchQuery(String query) {
        sendKeys(searchEditTextLocator, query);
    }

    public void performSearch(String query) {
        clickSearchContainer();
        enterSearchQuery(query);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    public void clickFirstSearchResult() {
        clickElement(searchResultsLocator);
    }

    public boolean isSearchContainerDisplayed() {
        return isElementDisplayed(searchContainerLocator);
    }

    public String getFirstSearchResultTitle() {
        return getText(searchResultsLocator);
    }

    public void openMoreOptions() {
        if (isElementDisplayed(moreOptionsButtonLocator)) {
            clickElement(moreOptionsButtonLocator);
        }
    }

    public void openSettings() {
        if (isElementDisplayed(settingsButtonLocator)) {
            clickElement(settingsButtonLocator);
        }
    }

    public void clickExploreTab() {
        if (isElementDisplayed(exploreTabLocator)) {
            clickElement(exploreTabLocator);
        }
    }

    public void clickSearchTab() {
        if (isElementDisplayed(searchTabLocator)) {
            clickElement(searchTabLocator);
        }
    }
}

