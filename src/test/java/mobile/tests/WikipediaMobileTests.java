package mobile.tests;

import mobile.base.MobileTestBase;
import mobile.pages.WikipediaArticlePage;
import mobile.pages.WikipediaSearchPage;
import org.testng.Assert;
import org.testng.annotations.Test;

/**
 * Набор мобильных тестов для приложения Wikipedia.
 * Реализованы как минимум 3 стабильных сценария.
 */
public class WikipediaMobileTests extends MobileTestBase {

    @Test(description = "Поиск статьи 'Appium' и проверка, что открыта корректная статья")
    public void searchAppiumArticle_shouldOpenCorrectPage() {
        WikipediaSearchPage searchPage = new WikipediaSearchPage(driver);
        searchPage.tapOnSearchContainer();
        searchPage.typeSearchQuery("Appium");
        searchPage.openFirstResult();

        WikipediaArticlePage articlePage = new WikipediaArticlePage(driver);
        String title = articlePage.getArticleTitle("Appium");
        Assert.assertTrue(title.toLowerCase().contains("appium"),
                "Заголовок статьи должен содержать 'Appium', фактический: " + title);
    }

    @Test(description = "Поиск статьи 'Selenium (software)' и проверка точного заголовка")
    public void searchSeleniumArticle_shouldHaveExactTitle() {
        WikipediaSearchPage searchPage = new WikipediaSearchPage(driver);
        searchPage.tapOnSearchContainer();
        searchPage.typeSearchQuery("Selenium (software)");
        searchPage.openFirstResult();

        WikipediaArticlePage articlePage = new WikipediaArticlePage(driver);
        String title = articlePage.getArticleTitle("Selenium (software)");
        Assert.assertEquals(title, "Selenium (software)",
                "Ожидался заголовок 'Selenium (software)', фактический: " + title);
    }

    @Test(description = "Прокрутка статьи вниз и проверка, что контент доступен (scroll scenario)")
    public void openArticleAndScroll_shouldKeepContentVisible() {
        WikipediaSearchPage searchPage = new WikipediaSearchPage(driver);
        searchPage.tapOnSearchContainer();
        searchPage.typeSearchQuery("Software testing");
        searchPage.openFirstResult();

        WikipediaArticlePage articlePage = new WikipediaArticlePage(driver);
        String initialTitle = articlePage.getArticleTitle("Software testing");
        articlePage.scrollDown();

        // После прокрутки заголовок статьи по‑прежнему должен быть доступен в структуре страницы
        String titleAfterScroll = articlePage.getArticleTitle("Software testing");
        Assert.assertEquals(titleAfterScroll, initialTitle,
                "Заголовок статьи после прокрутки должен совпадать с исходным");
    }
}





