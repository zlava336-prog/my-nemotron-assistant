import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('hi', ''),
  ];

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    if (locale.languageCode == 'hi') {
      _localizedStrings = {
        'appTitle': 'मेरा नेमोट्रॉन असिस्टेंट',
        'chatScreenTitle': 'चैट',
        'settingsTitle': 'सेटिंग्स',
        'apiKeyLabel': 'नेमोट्रॉन API कुंजी',
        'apiKeyHint': 'अपना NVIDIA नेमोट्रॉन API कुंजी दर्ज करें',
        'saveApiKey': 'API कुंजी सहेजें',
        'clearChat': 'चैट साफ़ करें',
        'clearChatConfirm': 'क्या आप वाकई चैट इतिहास साफ़ करना चाहते हैं?',
        'cancel': 'रद्द करें',
        'confirm': 'पुष्टि करें',
        'messagePlaceholder': 'संदेश टाइप करें...',
        'send': 'भेजें',
        'thinking': 'सोच रहा हूँ...',
        'error': 'त्रुटि',
        'noApiKey': 'कृपया सेटिंग्स में अपना नेमोट्रॉन API कुंजी सेट करें',
        'apiKeySaved': 'API कुंजी सहेजी गई!',
        'language': 'भाषा',
        'english': 'अंग्रेज़ी',
        'hindi': 'हिंदी',
        'theme': 'थीम',
        'light': 'लाइट',
        'dark': 'डार्क',
        'system': 'सिस्टम',
        'about': 'इस ऐप के बारे में',
        'version': 'संस्करण 1.0.0',
        'poweredBy': 'NVIDIA नेमोट्रॉन 3 अल्ट्रा द्वारा संचालित',
        'welcomeMessage': 'नमस्ते! मैं आपका नेमोट्रॉन असिस्टेंट हूँ। मैं आपकी कैसे मदद कर सकता हूँ?',
      };
    } else {
      _localizedStrings = {
        'appTitle': 'My Nemotron Assistant',
        'chatScreenTitle': 'Chat',
        'settingsTitle': 'Settings',
        'apiKeyLabel': 'Nemotron API Key',
        'apiKeyHint': 'Enter your NVIDIA Nemotron API key',
        'saveApiKey': 'Save API Key',
        'clearChat': 'Clear Chat',
        'clearChatConfirm': 'Are you sure you want to clear the chat history?',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
        'messagePlaceholder': 'Type a message...',
        'send': 'Send',
        'thinking': 'Thinking...',
        'error': 'Error',
        'noApiKey': 'Please set your Nemotron API key in settings',
        'apiKeySaved': 'API key saved!',
        'language': 'Language',
        'english': 'English',
        'hindi': 'Hindi',
        'theme': 'Theme',
        'light': 'Light',
        'dark': 'Dark',
        'system': 'System',
        'about': 'About',
        'version': 'Version 1.0.0',
        'poweredBy': 'Powered by NVIDIA Nemotron 3 Ultra',
        'welcomeMessage': 'Hello! I\'m your Nemotron Assistant. How can I help you today?',
      };
    }
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String get appTitle => translate('appTitle');
  String get chatScreenTitle => translate('chatScreenTitle');
  String get settingsTitle => translate('settingsTitle');
  String get apiKeyLabel => translate('apiKeyLabel');
  String get apiKeyHint => translate('apiKeyHint');
  String get saveApiKey => translate('saveApiKey');
  String get clearChat => translate('clearChat');
  String get clearChatConfirm => translate('clearChatConfirm');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get messagePlaceholder => translate('messagePlaceholder');
  String get send => translate('send');
  String get thinking => translate('thinking');
  String get error => translate('error');
  String get noApiKey => translate('noApiKey');
  String get apiKeySaved => translate('apiKeySaved');
  String get language => translate('language');
  String get english => translate('english');
  String get hindi => translate('hindi');
  String get theme => translate('theme');
  String get light => translate('light');
  String get dark => translate('dark');
  String get system => translate('system');
  String get about => translate('about');
  String get version => translate('version');
  String get poweredBy => translate('poweredBy');
  String get welcomeMessage => translate('welcomeMessage');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}