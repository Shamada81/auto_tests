package mobile.pages;

import io.appium.java_client.MobileElement;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.MobileBy;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Главный/поисковый экран приложения Wikipedia.
 * Локаторы могут отличаться в зависимости от версии приложения,
 * но выбраны максимально стабильные id.
 */
public class WikipediaSearchPage {

    private final AndroidDriver<MobileElement> driver;
    private final WebDriverWait wait;

    private final By searchContainer = By.id("org.wikipedia:id/search_container");
    private final By searchAction = By.id("org.wikipedia:id/search_action");
    private final By searchCard = By.id("org.wikipedia:id/search_card");
    private final By searchActionBar = By.id("org.wikipedia:id/search_actionbar");
    private final By searchInput = By.id("org.wikipedia:id/search_src_text");
    private final By firstSearchResult = By.id("org.wikipedia:id/page_list_item_title");
    // Онбординг (разные варианты кнопок в новых версиях приложения)
    private final By onboardingSkip = By.id("org.wikipedia:id/fragment_onboarding_skip_button");
    private final By onboardingDone = By.id("org.wikipedia:id/fragment_onboarding_done_button");
    private final By onboardingGetStarted = By.id("org.wikipedia:id/fragment_onboarding_button");
    private final By onboardingForward = By.id("org.wikipedia:id/fragment_onboarding_forward_button");
    private final By onboardingPrimary = By.id("org.wikipedia:id/primaryTextView");
    // Типовые кнопки диалогов (в том числе промо/игры)
    private final By dialogPositive = By.id("android:id/button1");
    private final By dialogNegative = By.id("android:id/button2");
    private final By dialogNeutral = By.id("android:id/button3");
    private final By dialogClose = By.id("org.wikipedia:id/dialog_button");
    private final By dialogCloseAlt = By.id("org.wikipedia:id/negativeButton");
    private final By dialogCloseAlt2 = By.id("org.wikipedia:id/positiveButton");
    private final By toolbarNavigateUp = MobileBy.AccessibilityId("Navigate up");
    private final By closeButton = MobileBy.AccessibilityId("Close");
    private final By promoCloseIcon = By.id("org.wikipedia:id/close");
    // Кнопки нижнего меню / поиска
    private final By navSearchTab = By.id("org.wikipedia:id/nav_tab_search");
    private final By navSearchText = By.xpath("//*[@text='Search' or @text='Поиск']");
    private final By navSearchDesc = MobileBy.AccessibilityId("Search");
    private final By searchToolbar = By.id("org.wikipedia:id/search_toolbar");
    // Дополнительные варианты кнопок/текстов для новых онбордингов
    private final String[] onboardingTexts = new String[] {
            "Skip", "SKIP", "Пропустить",
            "Continue", "CONTINUE", "Продолжить",
            "Get started", "GET STARTED", "Начать", "НАЧАТЬ",
            "Next", "Далее", "Вперёд", "Вперёд »", "Вперёд »"
    };
    // Попап "Introducing Wikipedia games" и похожие промо
    private final String[] promoTexts = new String[] {
            "Introducing Wikipedia games",
            "Wikipedia games",
            "Play now", "Try now", "Start playing",
            "No thanks", "Not now", "Maybe later", "Skip",
            "Dismiss", "Close",
            "Продолжить", "Пропустить", "Не сейчас"
    };

    public WikipediaSearchPage(AndroidDriver<MobileElement> driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, 30);
    }

    private boolean clickIfPresent(By locator) {
        try {
            driver.findElement(locator).click();
            return true;
        } catch (Exception ignored) {
            return false;
        }
    }

    private boolean clickIfTextPresent(String... texts) {
        for (String text : texts) {
            try {
                driver.findElement(By.xpath("//*[@text='" + text + "']")).click();
                return true;
            } catch (Exception ignored) {
                // пробуем следующий текст
            }
            try {
                // fallback: contains (для длинных сообщений/других регистров)
                driver.findElement(By.xpath("//*[contains(@text, '" + text + "')]")).click();
                return true;
            } catch (Exception ignored) {
                // продолжаем
            }
        }
        return false;
    }

    private void shortPause() {
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    /**
     * Универсальная попытка закрыть диалоги/попапы, в том числе "Introducing Wikipedia games".
     */
    private boolean closeDialogsIfAny() {
        // Сперва пытаемся нажать типовые кнопки/иконки закрытия
        boolean clicked = clickIfPresent(dialogNegative) ||
                clickIfPresent(dialogPositive) ||
                clickIfPresent(dialogNeutral) ||
                clickIfPresent(dialogClose) ||
                clickIfPresent(dialogCloseAlt) ||
                clickIfPresent(dialogCloseAlt2) ||
                clickIfPresent(promoCloseIcon) ||
                clickIfPresent(closeButton) ||
                clickIfPresent(toolbarNavigateUp) ||
                clickIfTextPresent(promoTexts);

        // Если на экране реально есть текст про игры — пробуем Back/secondary button
        if (!clicked) {
            try {
                if (!driver.findElements(By.xpath("//*[contains(@text,'Wikipedia games')]")).isEmpty()) {
                    clicked = clickIfPresent(dialogNegative) ||
                            clickIfPresent(dialogCloseAlt) ||
                            clickIfTextPresent("No thanks", "Not now", "Maybe later", "Пропустить", "Не сейчас");
                }
            } catch (Exception ignored) {}
        }

        if (clicked) {
            shortPause();
        }
        return clicked;
    }

    /**
     * Закрываем онбординг/приветственные экраны, если они ещё показываются.
     * Перебираем популярные кнопки: Skip / Done / Get started / Forward.
     */
    private void ensureOnboardingClosed() {
        // Быстрый выход, если уже видим поисковой контейнер
        if (!driver.findElements(searchContainer).isEmpty()) {
            return;
        }

        // Пробуем несколько шагов онбординга/промо (до 8 экранов)
        for (int i = 0; i < 8; i++) {
            if (clickIfPresent(onboardingSkip) ||
                clickIfPresent(onboardingDone) ||
                clickIfPresent(onboardingGetStarted) ||
                clickIfPresent(onboardingForward) ||
                clickIfPresent(onboardingPrimary) ||
                clickIfTextPresent(onboardingTexts) ||
                closeDialogsIfAny()) {
                shortPause();
                if (!driver.findElements(searchContainer).isEmpty()) {
                    return;
                }
            }
            // Дополнительно пробуем закрыть диалоги на каждом шаге
            closeDialogsIfAny();
            shortPause();
        }
        // Финальная попытка: ждём появления контейнера (если онбординг сам исчезнет)
        try {
            new WebDriverWait(driver, 10).until(ExpectedConditions.presenceOfElementLocated(searchContainer));
        } catch (Exception ignored) {
            // если не появился, дальше выбросится стандартный timeout
        }
    }

    public void tapOnSearchContainer() {
        // 1) закрываем онбординг/диалоги
        ensureOnboardingClosed();
        closeDialogsIfAny();

        // 2) если уже на экране поиска — просто выходим
        if (!driver.findElements(searchInput).isEmpty()) {
            return;
        }

        // 3) явный запуск SearchActivity (самый стабильный путь)
        try {
            driver.startActivity(new io.appium.java_client.android.Activity("org.wikipedia", "org.wikipedia.search.SearchActivity"));
            shortPause();
        } catch (Exception ignored) {
            // если не получилось — пробуем клик по доступным элементам
            clickIfPresent(searchContainer);
            clickIfPresent(searchAction);
            clickIfPresent(searchCard);
            clickIfPresent(searchActionBar);
            clickIfPresent(navSearchTab);
            clickIfPresent(navSearchDesc);
            clickIfPresent(navSearchText);
            clickIfPresent(searchToolbar);
        }

        // 4) ждём поле ввода поиска
        wait.until(ExpectedConditions.presenceOfElementLocated(searchInput));
        try {
            driver.findElement(searchInput).click();
        } catch (Exception ignored) {
            // в крайнем случае — контейнер
            try {
                driver.findElement(searchContainer).click();
            } catch (Exception ignoredInner) {}
        }
    }

    public void typeSearchQuery(String query) {
        wait.until(ExpectedConditions.presenceOfElementLocated(searchInput));
        driver.findElement(searchInput).clear();
        driver.findElement(searchInput).sendKeys(query);
        // Небольшая задержка для появления результатов поиска
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    public void openFirstResult() {
        new WebDriverWait(driver, 25).until(ExpectedConditions.presenceOfElementLocated(firstSearchResult));
        driver.findElements(firstSearchResult).get(0).click();
    }
}


