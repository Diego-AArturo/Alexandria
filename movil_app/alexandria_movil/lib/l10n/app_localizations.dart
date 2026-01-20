import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// Shown when mandatory auth form fields are missing.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get authFillRequiredFields;

  /// Title for the sign-in mode.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authTitleSignIn;

  /// Title for the create account mode.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authTitleCreateAccount;

  /// Label for the email input.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLabelEmail;

  /// Label for the name input.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authLabelName;

  /// Label for the password input.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authLabelPassword;

  /// Primary button label for sign-in flow.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authPrimaryContinue;

  /// Primary button label for sign-up flow.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authPrimaryCreateAccount;

  /// Shown while Google sign-in is in progress.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authGoogleSigningIn;

  /// Button label to start Google sign-in.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogleContinue;

  /// Toggle prompt shown on sign-in mode.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up'**
  String get authToggleNoAccount;

  /// Toggle prompt shown on sign-up mode.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authToggleHasAccount;

  /// Snackbar message when email/password auth fails.
  ///
  /// In en, this message translates to:
  /// **'Auth failed: {error}'**
  String authSnackbarAuthFailed(String error);

  /// Snackbar message when Google sign-in fails.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String authSnackbarGoogleFailed(String error);

  /// Error shown when user cancels Google sign-in.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authErrorGoogleCancelled;

  /// Error shown when Google idToken is not returned.
  ///
  /// In en, this message translates to:
  /// **'Missing Google idToken'**
  String get authErrorGoogleMissingIdToken;

  /// Prompt shown when user is not signed in.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to load courses.'**
  String get courseHomeSignInPrompt;

  /// Page title for the course home screen.
  ///
  /// In en, this message translates to:
  /// **'My courses'**
  String get courseHomeTitle;

  /// Error when user courses fail to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load courses: {error}'**
  String courseHomeLoadFailed(String error);

  /// Empty state text when the user has no courses.
  ///
  /// In en, this message translates to:
  /// **'No courses yet. Generate one to get started.'**
  String get courseHomeEmptyState;

  /// Short progress label shown on course cards.
  ///
  /// In en, this message translates to:
  /// **'Progress {percent}%'**
  String courseHomeProgressLabel(int percent);

  /// Fallback unit title using a unit number.
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String unitNumberLabel(int number);

  /// Progress label shown on the course detail header.
  ///
  /// In en, this message translates to:
  /// **'Progress {percent}%'**
  String courseUnitsProgressLabel(int percent);

  /// Indicates the current unit position.
  ///
  /// In en, this message translates to:
  /// **'You are in Unit {current} of {total}'**
  String courseUnitsCurrentLabel(int current, int total);

  /// Error message when loading course progress fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load progress: {error}'**
  String courseUnitsLoadFailed(String error);

  /// Header subtitle when viewing a concept.
  ///
  /// In en, this message translates to:
  /// **'Concept {current} of {total}'**
  String courseScreenConceptCounter(int current, int total);

  /// Header subtitle when answering a question.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String courseScreenQuestionCounter(int current, int total);

  /// Button label to submit an answer.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get courseScreenSubmitAnswer;

  /// Generic continue button label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get courseScreenContinue;

  /// Shown when a unit has no content.
  ///
  /// In en, this message translates to:
  /// **'No content available for this unit.'**
  String get courseScreenNoContent;

  /// Fallback content when the unit has no generated items.
  ///
  /// In en, this message translates to:
  /// **'Content for this unit is not available yet.'**
  String get courseScreenPlaceholderContent;

  /// Fallback concept title combining unit title and a concept index.
  ///
  /// In en, this message translates to:
  /// **'{unitTitle} - Concept {number}'**
  String courseScreenFallbackConceptTitle(String unitTitle, int number);

  /// Page title for the course creation screen.
  ///
  /// In en, this message translates to:
  /// **'Craft a Course'**
  String get craftCourseTitle;

  /// Subtitle explaining how to craft a course.
  ///
  /// In en, this message translates to:
  /// **'Describe what you want to learn and we\'ll create a short, tailored course for you.'**
  String get craftCourseSubtitle;

  /// Hint text for the course prompt input.
  ///
  /// In en, this message translates to:
  /// **'Example: I want to learn the basics of Python to automate simple tasks.'**
  String get craftCoursePromptHint;

  /// Button label to submit a course creation request.
  ///
  /// In en, this message translates to:
  /// **'Create Course'**
  String get craftCourseSubmitLabel;

  /// Button label while submitting a course creation request.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get craftCourseSubmittingLabel;

  /// Snackbar message when the course prompt is empty.
  ///
  /// In en, this message translates to:
  /// **'Please describe the course you want.'**
  String get craftCourseToastEmptyPrompt;

  /// Snackbar message after submitting a course job.
  ///
  /// In en, this message translates to:
  /// **'Course queued. We will notify you when it is ready.'**
  String get craftCourseQueuedMessage;

  /// Error message when course generation fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate course: {error}'**
  String craftCourseGenerateFailed(String error);

  /// Fallback course title when not provided by backend.
  ///
  /// In en, this message translates to:
  /// **'Generated course'**
  String get craftCourseGeneratedTitleFallback;

  /// Fallback course description when not provided by backend.
  ///
  /// In en, this message translates to:
  /// **'Your generated course'**
  String get craftCourseGeneratedDescriptionFallback;

  /// Error shown when navigation to the generated course fails.
  ///
  /// In en, this message translates to:
  /// **'Course generated but failed to open: {error}'**
  String craftCourseOpenFailed(String error);

  /// Title for the tips list on course creation screen.
  ///
  /// In en, this message translates to:
  /// **'Tips for great courses:'**
  String get craftCourseTipsTitle;

  /// Tip encouraging users to include their learning goals.
  ///
  /// In en, this message translates to:
  /// **'Be specific about your learning goals'**
  String get craftCourseTipSpecificGoals;

  /// Tip encouraging users to share their current skill level.
  ///
  /// In en, this message translates to:
  /// **'Mention your current knowledge level'**
  String get craftCourseTipKnowledgeLevel;

  /// Tip encouraging users to list topics of interest.
  ///
  /// In en, this message translates to:
  /// **'Include any specific topics you want covered'**
  String get craftCourseTipTopics;

  /// Prompt shown when user is not signed in but opens profile.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your profile.'**
  String get profileSignInPrompt;

  /// Error message when profile data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String profileLoadFailed(String error);

  /// Page title for the profile screen.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// Placeholder name for unsigned users.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestName;

  /// Placeholder subtitle when user is not signed in.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileNotSignedIn;

  /// Label for total courses metric.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get profileCoursesTitle;

  /// Caption for total courses metric.
  ///
  /// In en, this message translates to:
  /// **'Total courses'**
  String get profileCoursesTotalLabel;

  /// Label for completed courses metric.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get profileCompletedTitle;

  /// Caption for completed courses metric.
  ///
  /// In en, this message translates to:
  /// **'Courses completed'**
  String get profileCoursesCompletedLabel;

  /// Label for in-progress courses metric.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get profileInProgressTitle;

  /// Caption for in-progress courses metric.
  ///
  /// In en, this message translates to:
  /// **'Courses currently active'**
  String get profileCoursesActiveLabel;

  /// Section title for account info.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get profileAccountInfoTitle;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
