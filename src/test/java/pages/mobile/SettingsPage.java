package pages.mobile;

import io.appium.java_client.AppiumBy;
import org.openqa.selenium.By;

public class SettingsPage extends BaseMobilePage {
    
    private By languageSettingsLocator = AppiumBy.xpath("//android.widget.TextView[@text='Language']");
    private By wikipediaLanguagesLocator = AppiumBy.xpath("//android.widget.TextView[@text='Wikipedia languages']");
    private By addLanguageButtonLocator = AppiumBy.id("org.wikipedia:id/preference_languages_add_language");
    private By languageListLocator = AppiumBy.id("org.wikipedia:id/language_list");
    private By russianLanguageLocator = AppiumBy.xpath("//android.widget.TextView[@text='Русский']");
    private By englishLanguageLocator = AppiumBy.xpath("//android.widget.TextView[@text='English']");
    private By backButtonLocator = AppiumBy.accessibilityId("Navigate up");

    public SettingsPage() {
        super();
    }

    public void openLanguageSettings() {
        if (isElementDisplayed(languageSettingsLocator)) {
            clickElement(languageSettingsLocator);
        } else if (isElementDisplayed(wikipediaLanguagesLocator)) {
            clickElement(wikipediaLanguagesLocator);
        }
    }

    public void addLanguage(String languageName) {
        if (isElementDisplayed(addLanguageButtonLocator)) {
            clickElement(addLanguageButtonLocator);
        }
        
        By languageLocator = AppiumBy.xpath("//android.widget.TextView[@text='" + languageName + "']");
        if (isElementDisplayed(languageLocator)) {
            clickElement(languageLocator);
        }
    }

    public void selectRussianLanguage() {
        if (isElementDisplayed(russianLanguageLocator)) {
            clickElement(russianLanguageLocator);
        }
    }

    public void selectEnglishLanguage() {
        if (isElementDisplayed(englishLanguageLocator)) {
            clickElement(englishLanguageLocator);
        }
    }

    public void goBack() {
        if (isElementDisplayed(backButtonLocator)) {
            clickElement(backButtonLocator);
        } else {
            driver.navigate().back();
        }
    }
}

