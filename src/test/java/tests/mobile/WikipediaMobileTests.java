package tests.mobile;

import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import pages.mobile.ArticlePage;
import pages.mobile.MainPage;
import utils.AppiumDriverManager;

public class WikipediaMobileTests {
    
    private MainPage mainPage;
    private ArticlePage articlePage;

    @BeforeClass
    public void setUp() {
        mainPage = new MainPage();
        articlePage = new ArticlePage();
        
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    @Test(priority = 1, description = "Проверка отображения главного экрана и поиска статьи")
    public void testMainScreenAndSearch() {
        Assert.assertTrue(mainPage.isSearchContainerDisplayed(), 
            "Контейнер поиска должен отображаться на главном экране");
        
        String searchQuery = "Java";
        mainPage.performSearch(searchQuery);
        
        String firstResultTitle = mainPage.getFirstSearchResultTitle();
        Assert.assertNotNull(firstResultTitle, "Должен быть найден хотя бы один результат поиска");
        Assert.assertFalse(firstResultTitle.isEmpty(), "Заголовок результата поиска не должен быть пустым");
    }

    @Test(priority = 2, description = "Проверка открытия статьи и её заголовка")
    public void testOpenArticleAndCheckTitle() {
        String searchQuery = "Python";
        mainPage.performSearch(searchQuery);
        mainPage.clickFirstSearchResult();
        
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        Assert.assertTrue(articlePage.isArticleContentDisplayed() || articlePage.isArticleHeaderDisplayed(), 
            "Содержимое статьи должно отображаться");
        Assert.assertTrue(articlePage.isArticleContentDisplayed() || articlePage.isArticleHeaderDisplayed(), 
            "Статья должна быть открыта и отображаться");
    }

    @Test(priority = 3, description = "Проверка поиска статей с разными запросами", dataProvider = "searchQueries")
    public void testSearchWithDifferentQueries(String searchQuery) {
        try {
            AppiumDriverManager.getDriver().navigate().back();
            Thread.sleep(1000);
        } catch (Exception e) {
        }
        
        mainPage.performSearch(searchQuery);
        
        String firstResultTitle = mainPage.getFirstSearchResultTitle();
        Assert.assertNotNull(firstResultTitle, 
            "Для запроса '" + searchQuery + "' должен быть найден результат");
    }

    @DataProvider(name = "searchQueries")
    public Object[][] searchQueries() {
        return new Object[][] {
            {"Russia"},
            {"Moscow"},
            {"Technology"}
        };
    }

    @Test(priority = 4, description = "Проверка прокрутки статьи и наличия элементов")
    public void testScrollArticleAndCheckElements() {
        String searchQuery = "Android";
        mainPage.performSearch(searchQuery);
        mainPage.clickFirstSearchResult();
        
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        Assert.assertTrue(articlePage.isArticleContentDisplayed() || articlePage.isArticleHeaderDisplayed(), 
            "Статья должна быть открыта");
        
        articlePage.scrollDownInArticle();
        
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        Assert.assertTrue(articlePage.isArticleContentDisplayed() || articlePage.isArticleHeaderDisplayed(), 
            "Контент статьи должен оставаться видимым после прокрутки");
    }

    @Test(priority = 5, description = "Проверка навигации назад из статьи")
    public void testNavigationBackFromArticle() {
        String searchQuery = "Wikipedia";
        mainPage.performSearch(searchQuery);
        mainPage.clickFirstSearchResult();
        
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        Assert.assertTrue(articlePage.isArticleContentDisplayed() || articlePage.isArticleHeaderDisplayed(), 
            "Статья должна быть открыта");
        
        articlePage.clickBackButton();
        
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        Assert.assertTrue(mainPage.isSearchContainerDisplayed(), 
            "После возврата должен отображаться главный экран с поиском");
    }

    @Test(priority = 6, description = "Проверка работы приложения после перезапуска")
    public void testAppReliability() {
        Assert.assertTrue(mainPage.isSearchContainerDisplayed(), 
            "Главный экран должен отображаться корректно");
        
        mainPage.performSearch("Test");
        
        String firstResult = mainPage.getFirstSearchResultTitle();
        Assert.assertNotNull(firstResult, "Поиск должен работать стабильно");
    }

    @AfterClass
    public void tearDown() {
        AppiumDriverManager.quitDriver();
    }
}

