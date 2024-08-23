class Translator {
  // English language map object
  Map<String, dynamic> en = {
    "home": "Home",
    "about_us": "About us",
    "more": "More",
    "server_ip":"Server_IP",
    "select-language":"Select-Language"
  };

  // Hindi language map object
  Map<String, dynamic> hi = {
    "home": "घर",
    "about_us": "हमारे बारे में",
    "more": "अधिक",
    "server_ip":"को हिंदी में सर्वर-आईपी कहा जाता है।",
    "select-language":"भाषा चुनें"
  };


  // Method to return the selected language map
  dynamic to(String selectedLanguage) {
    if (selectedLanguage == "English") {
      return en;
    } else if (selectedLanguage == "Hindi") {
      return hi;
    } 
  }

  // Method to translate a key to the selected language
  String translate(String selectedLanguage, String text) {
    return to(selectedLanguage)[text.toLowerCase().replaceAll(" ", "_")];
  }
}

// Enum to represent the supported languages
enum LanguagesEnum { English, Hindi }
