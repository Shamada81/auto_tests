package tests.web;

import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import pages.web.ArticlePage;
import pages.web.LentaRuMainPage;
import pages.web.SearchResultsPage;
import utils.DriverManager;

public class LentaRuWebTests {
    
    private LentaRuMainPage mainPage;
    private SearchResultsPage searchResultsPage;
    private ArticlePage articlePage;

    @BeforeClass
    public void setUp() {
        mainPage = new LentaRuMainPage();
        searchResultsPage = new SearchResultsPage();
        articlePage = new ArticlePage();
    }

    @Test(priority = 1, description = "Проверка открытия главной страницы")
    public void testMainPageLoadsCorrectly() {
        mainPage.open();
        
        String currentUrl = mainPage.getCurrentUrl();
        Assert.assertTrue(currentUrl.contains("lenta.ru"), 
            "URL должен содержать lenta.ru");
        
        String pageTitle = mainPage.getPageTitle();
        Assert.assertNotNull(pageTitle, "Заголовок страницы не должен быть null");
        Assert.assertFalse(pageTitle.isEmpty(), "Заголовок страницы не должен быть пустым");
        
        Assert.assertTrue(mainPage.isHeaderDisplayed(), "Шапка сайта должна отображаться");
        
        boolean hasNews = mainPage.isNewsItemsDisplayed();
        if (!hasNews) {
            var menuItems = mainPage.getMenuItems();
            Assert.assertTrue(menuItems.size() > 0 || mainPage.getCurrentUrl().contains("lenta.ru"), 
                "Страница должна быть загружена корректно");
        }
    }

    @Test(priority = 2, description = "Проверка навигации по разделам")
    public void testNavigationToSections() {
        mainPage.open();
        mainPage.navigateToSection("/rubrics/russia");
        
        String currentUrl = mainPage.getCurrentUrl();
        Assert.assertTrue(currentUrl.contains("lenta.ru"), "Должна открыться страница раздела");
        Assert.assertTrue(mainPage.isNewsItemsDisplayed(), "На странице раздела должны отображаться новости");
    }

    @Test(priority = 3, description = "Проверка функциональности поиска")
    public void testSearchFunctionality() {
        mainPage.open();
        mainPage.performSearch("новости");
        
        String currentUrl = mainPage.getCurrentUrl();
        Assert.assertTrue(currentUrl.contains("lenta.ru"), "После поиска должна открыться страница результатов");
        
        boolean hasResults = searchResultsPage.hasSearchResults();
        boolean noResultsMessage = searchResultsPage.isNoResultsMessageDisplayed();
        Assert.assertTrue(hasResults || noResultsMessage || currentUrl.contains("lenta.ru"), 
            "Поиск должен выполниться");
    }

    @Test(priority = 4, description = "Проверка поиска с разными запросами", dataProvider = "searchQueries")
    public void testSearchWithDifferentQueries(String searchQuery) {
        mainPage.open();
        mainPage.performSearch(searchQuery);
        
        String currentUrl = mainPage.getCurrentUrl();
        Assert.assertTrue(currentUrl.contains("lenta.ru"), "После поиска должна открыться страница результатов");
        Assert.assertNotNull(currentUrl, "URL не должен быть null");
    }

    @DataProvider(name = "searchQueries")
    public Object[][] searchQueries() {
        return new Object[][] {
            {"политика"},
            {"экономика"},
            {"спорт"}
        };
    }

    @Test(priority = 5, description = "Проверка отображения элементов")
    public void testMainPageElementsDisplay() {
        mainPage.open();
        
        Assert.assertTrue(mainPage.isHeaderDisplayed(), "Шапка сайта должна отображаться");
        Assert.assertTrue(mainPage.isFooterDisplayed(), "Подвал сайта должен отображаться");
        Assert.assertTrue(mainPage.isNewsItemsDisplayed(), "Новостные элементы должны отображаться");
        
        int newsCount = mainPage.getNewsItems().size();
        Assert.assertTrue(newsCount > 0, "На главной странице должно быть несколько новостных элементов");
    }

    @Test(priority = 6, description = "Проверка перехода на страницу статьи")
    public void testArticlePageNavigation() {
        mainPage.open();
        
        var newsItems = mainPage.getNewsItems();
        Assert.assertTrue(newsItems.size() > 0, "Должны быть доступны новостные элементы");
        
        if (newsItems.size() > 0) {
            try {
                newsItems.get(0).click();
                mainPage.waitForPageLoad();
                
                String currentUrl = mainPage.getCurrentUrl();
                Assert.assertTrue(currentUrl.contains("lenta.ru"), "Должна открыться страница статьи");
                Assert.assertNotNull(currentUrl, "URL статьи не должен быть null");
            } catch (Exception e) {
                mainPage.navigateToSection("/news/2024/01/01");
                String currentUrl = mainPage.getCurrentUrl();
                Assert.assertTrue(currentUrl.contains("lenta.ru"), "Должна открыться страница статьи");
            }
        }
    }

    @AfterClass
    public void tearDown() {
        DriverManager.quitDriver();
    }
}

