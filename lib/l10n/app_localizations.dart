import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

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
    Locale('en'),
    Locale('ml'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GreenLoop Waste Management'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @ward.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get ward;

  /// No description provided for @smartCityDistrict.
  ///
  /// In en, this message translates to:
  /// **'Smart City District'**
  String get smartCityDistrict;

  /// No description provided for @nextCollection.
  ///
  /// In en, this message translates to:
  /// **'NEXT COLLECTION'**
  String get nextCollection;

  /// No description provided for @planNextCollection.
  ///
  /// In en, this message translates to:
  /// **'Plan Next Collection'**
  String get planNextCollection;

  /// No description provided for @readyToRecycle.
  ///
  /// In en, this message translates to:
  /// **'Ready to recycle? Schedule now.'**
  String get readyToRecycle;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'RECENT ACTIVITY'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity detected'**
  String get noActivity;

  /// No description provided for @navDash.
  ///
  /// In en, this message translates to:
  /// **'DASH'**
  String get navDash;

  /// No description provided for @navBook.
  ///
  /// In en, this message translates to:
  /// **'BOOK'**
  String get navBook;

  /// No description provided for @navEarn.
  ///
  /// In en, this message translates to:
  /// **'EARN'**
  String get navEarn;

  /// No description provided for @navSelf.
  ///
  /// In en, this message translates to:
  /// **'SELF'**
  String get navSelf;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

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

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'STEP'**
  String get step;

  /// No description provided for @onboard1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GreenLoop'**
  String get onboard1Title;

  /// No description provided for @onboard1Sub.
  ///
  /// In en, this message translates to:
  /// **'Your smart waste management solution for Kozhikode'**
  String get onboard1Sub;

  /// No description provided for @onboard1Desc.
  ///
  /// In en, this message translates to:
  /// **'Together, let\'s build a cleaner, greener city'**
  String get onboard1Desc;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Easy Pickup Booking'**
  String get onboard2Title;

  /// No description provided for @onboard2Sub.
  ///
  /// In en, this message translates to:
  /// **'Schedule waste collection at your convenience'**
  String get onboard2Sub;

  /// No description provided for @onboard2Desc.
  ///
  /// In en, this message translates to:
  /// **'Regular, bulk, and emergency pickups available'**
  String get onboard2Desc;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'Earn Rewards'**
  String get onboard3Title;

  /// No description provided for @onboard3Sub.
  ///
  /// In en, this message translates to:
  /// **'Get points for proper waste segregation'**
  String get onboard3Sub;

  /// No description provided for @onboard3Desc.
  ///
  /// In en, this message translates to:
  /// **'Redeem points for eco-friendly products'**
  String get onboard3Desc;

  /// No description provided for @onboard4Title.
  ///
  /// In en, this message translates to:
  /// **'Join the Movement'**
  String get onboard4Title;

  /// No description provided for @onboard4Sub.
  ///
  /// In en, this message translates to:
  /// **'Be part of Kozhikode\'s sustainability journey'**
  String get onboard4Sub;

  /// No description provided for @onboard4Desc.
  ///
  /// In en, this message translates to:
  /// **'Small actions, big impact for our planet'**
  String get onboard4Desc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueText;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @wardNumber.
  ///
  /// In en, this message translates to:
  /// **'Ward Number'**
  String get wardNumber;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details'**
  String get fillDetails;

  /// No description provided for @roleResident.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get roleResident;

  /// No description provided for @roleWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get roleWorker;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleRecycler.
  ///
  /// In en, this message translates to:
  /// **'Recycler'**
  String get roleRecycler;

  /// No description provided for @roleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get roleDriver;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @regSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get regSuccess;

  /// No description provided for @regFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get regFailed;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred:'**
  String get errorOccurred;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUpButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
