import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ms'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Halal Player'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Halal Player'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy-first media player with AI content protection'**
  String get welcomeSubtitle;

  /// No description provided for @protected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protected;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @openVideo.
  ///
  /// In en, this message translates to:
  /// **'Open Video'**
  String get openVideo;

  /// No description provided for @openAudio.
  ///
  /// In en, this message translates to:
  /// **'Open Audio'**
  String get openAudio;

  /// No description provided for @viewImage.
  ///
  /// In en, this message translates to:
  /// **'View Image'**
  String get viewImage;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolder;

  /// No description provided for @playWithProtection.
  ///
  /// In en, this message translates to:
  /// **'Play with AI protection'**
  String get playWithProtection;

  /// No description provided for @listenSafely.
  ///
  /// In en, this message translates to:
  /// **'Listen safely'**
  String get listenSafely;

  /// No description provided for @aiScanned.
  ///
  /// In en, this message translates to:
  /// **'AI-scanned before display'**
  String get aiScanned;

  /// No description provided for @browseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Browse media library'**
  String get browseLibrary;

  /// No description provided for @recentFiles.
  ///
  /// In en, this message translates to:
  /// **'Recent Files'**
  String get recentFiles;

  /// No description provided for @noRecentFiles.
  ///
  /// In en, this message translates to:
  /// **'No recent files'**
  String get noRecentFiles;

  /// No description provided for @openFileToStart.
  ///
  /// In en, this message translates to:
  /// **'Open a file to get started'**
  String get openFileToStart;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @contentLogs.
  ///
  /// In en, this message translates to:
  /// **'Content Logs'**
  String get contentLogs;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @totalAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Total Analyzed'**
  String get totalAnalyzed;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @blurred.
  ///
  /// In en, this message translates to:
  /// **'Blurred'**
  String get blurred;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @logsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Content analysis logs will appear here'**
  String get logsAppearHere;

  /// No description provided for @logsStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Logs are stored locally and never leave your device'**
  String get logsStoredLocally;

  /// No description provided for @clearAllLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear All Logs?'**
  String get clearAllLogs;

  /// No description provided for @clearLogsWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all content logs. This action cannot be undone.'**
  String get clearLogsWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logsCleared.
  ///
  /// In en, this message translates to:
  /// **'All logs have been cleared'**
  String get logsCleared;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @filteringMode.
  ///
  /// In en, this message translates to:
  /// **'Filtering Mode'**
  String get filteringMode;

  /// No description provided for @selectFilteringLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred filtering level'**
  String get selectFilteringLevel;

  /// No description provided for @strictIslamic.
  ///
  /// In en, this message translates to:
  /// **'Strict Islamic'**
  String get strictIslamic;

  /// No description provided for @strictIslamicDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum protection for Islamic households'**
  String get strictIslamicDesc;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @familyDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced protection for families'**
  String get familyDesc;

  /// No description provided for @teen.
  ///
  /// In en, this message translates to:
  /// **'Teen'**
  String get teen;

  /// No description provided for @teenDesc.
  ///
  /// In en, this message translates to:
  /// **'Age-appropriate filtering for teenagers'**
  String get teenDesc;

  /// No description provided for @educational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get educational;

  /// No description provided for @educationalDesc.
  ///
  /// In en, this message translates to:
  /// **'Relaxed filtering for educational content'**
  String get educationalDesc;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @developerDesc.
  ///
  /// In en, this message translates to:
  /// **'Minimal filtering for developers testing content'**
  String get developerDesc;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get threshold;

  /// No description provided for @aiBehavior.
  ///
  /// In en, this message translates to:
  /// **'AI Behavior'**
  String get aiBehavior;

  /// No description provided for @blurEffect.
  ///
  /// In en, this message translates to:
  /// **'Blur Effect'**
  String get blurEffect;

  /// No description provided for @blurEffectDesc.
  ///
  /// In en, this message translates to:
  /// **'Use blur instead of blocking content'**
  String get blurEffectDesc;

  /// No description provided for @autoSkipFlagged.
  ///
  /// In en, this message translates to:
  /// **'Auto Skip Flagged'**
  String get autoSkipFlagged;

  /// No description provided for @autoSkipFlaggedDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically skip detected content'**
  String get autoSkipFlaggedDesc;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @enableLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable Logging'**
  String get enableLogging;

  /// No description provided for @enableLoggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep record of blocked content (local only)'**
  String get enableLoggingDesc;

  /// No description provided for @aiExplanations.
  ///
  /// In en, this message translates to:
  /// **'AI Explanations'**
  String get aiExplanations;

  /// No description provided for @aiExplanationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show why content was blocked'**
  String get aiExplanationsDesc;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'All processing happens locally. Your media never leaves your device.'**
  String get privacyNote;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// No description provided for @subtitleSettings.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Settings'**
  String get subtitleSettings;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontColor.
  ///
  /// In en, this message translates to:
  /// **'Font Color'**
  String get fontColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @bottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get bottom;

  /// No description provided for @autoDownload.
  ///
  /// In en, this message translates to:
  /// **'Auto Download'**
  String get autoDownload;

  /// No description provided for @autoDownloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically download subtitles when available'**
  String get autoDownloadDesc;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @translateTo.
  ///
  /// In en, this message translates to:
  /// **'Translate to'**
  String get translateTo;

  /// No description provided for @autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto Detect'**
  String get autoDetect;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// No description provided for @noSubtitlesFound.
  ///
  /// In en, this message translates to:
  /// **'No subtitles found'**
  String get noSubtitlesFound;

  /// No description provided for @generateSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Generate Subtitles'**
  String get generateSubtitles;

  /// No description provided for @downloadSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Download Subtitles'**
  String get downloadSubtitles;

  /// No description provided for @islamicSafeMode.
  ///
  /// In en, this message translates to:
  /// **'Islamic Safe Mode'**
  String get islamicSafeMode;

  /// No description provided for @islamicSafeModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Filter inappropriate words in translations'**
  String get islamicSafeModeDesc;

  /// No description provided for @videoPlayer.
  ///
  /// In en, this message translates to:
  /// **'Video Player'**
  String get videoPlayer;

  /// No description provided for @audioPlayer.
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get audioPlayer;

  /// No description provided for @imageViewer.
  ///
  /// In en, this message translates to:
  /// **'Image Viewer'**
  String get imageViewer;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @noFileOpened.
  ///
  /// In en, this message translates to:
  /// **'No {type} file opened'**
  String noFileOpened(String type);

  /// No description provided for @openType.
  ///
  /// In en, this message translates to:
  /// **'Open {type}'**
  String openType(String type);

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @flagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get flagged;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @contentFlagged.
  ///
  /// In en, this message translates to:
  /// **'Content Flagged'**
  String get contentFlagged;

  /// No description provided for @aiFlaggedContent.
  ///
  /// In en, this message translates to:
  /// **'AI detected potentially inappropriate content'**
  String get aiFlaggedContent;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @viewAnyway.
  ///
  /// In en, this message translates to:
  /// **'View Anyway'**
  String get viewAnyway;

  /// No description provided for @contentBlocked.
  ///
  /// In en, this message translates to:
  /// **'Content Blocked'**
  String get contentBlocked;

  /// No description provided for @blockedByFilters.
  ///
  /// In en, this message translates to:
  /// **'This content has been blocked by AI safety filters'**
  String get blockedByFilters;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @privacyProtected.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is protected - this was analyzed locally'**
  String get privacyProtected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'hi',
    'id',
    'ja',
    'ms',
    'ru',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ms':
      return AppLocalizationsMs();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
