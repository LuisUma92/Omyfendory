// Enable custom CSS
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Skip first-run pages
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");

// Blank new tabs
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "about:blank");

// Disable pocket and sync for webapp use
user_pref("extensions.pocket.enabled", false);
