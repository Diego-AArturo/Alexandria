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

  /// Headline shown when the user has no courses, above the mock card.
  ///
  /// In en, this message translates to:
  /// **'Create your first course'**
  String get courseHomeEmptyMockTitle;

  /// Body copy explaining how to go to the Craft course tab from the empty state.
  ///
  /// In en, this message translates to:
  /// **'Use the Craft course tab to describe what you want to learn. Here\'s a sample of how your courses will look.'**
  String get courseHomeEmptyMockDescription;

  /// Sample course title shown on the mock card.
  ///
  /// In en, this message translates to:
  /// **'Example: Python for automating small tasks'**
  String get courseHomeEmptyMockSampleTitle;

  /// Sample course description shown on the mock card.
  ///
  /// In en, this message translates to:
  /// **'3 short units · Beginner friendly · Practical exercises'**
  String get courseHomeEmptyMockSampleDescription;

  /// CTA button label to guide users to the Craft course tab.
  ///
  /// In en, this message translates to:
  /// **'Go to Craft course'**
  String get courseHomeEmptyMockAction;

  /// Snackbar message reminding the user to tap the Craft course tab.
  ///
  /// In en, this message translates to:
  /// **'Open the Craft course tab below to start your first course.'**
  String get courseHomeEmptyMockActionHint;

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

  /// Header subtitle when reviewing questions in a retry phase.
  ///
  /// In en, this message translates to:
  /// **'Refresher {current} of {total}'**
  String courseScreenRetryCounter(int current, int total);

  /// Button label to submit an answer.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get courseScreenSubmitAnswer;

  /// Button label to go back to the previous item in a unit flow.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get courseScreenPrevious;

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

  /// Snackbar shown when user reached the beta limit of courses.
  ///
  /// In en, this message translates to:
  /// **'Beta limit reached: you can create up to {limit} courses.'**
  String craftCourseLimitReached(int limit);

  /// Snackbar shown when the app cannot validate current course count.
  ///
  /// In en, this message translates to:
  /// **'Could not validate your courses: {error}'**
  String craftCourseLimitCheckFailed(String error);

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

  /// Pill label on multiple-choice questions.
  ///
  /// In en, this message translates to:
  /// **'Select one'**
  String get courseScreenSelectOne;

  /// Pill label on true/false questions.
  ///
  /// In en, this message translates to:
  /// **'True or False'**
  String get courseScreenTrueOrFalse;

  /// Label for the True button in true/false questions.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get courseScreenTrue;

  /// Label for the False button in true/false questions.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get courseScreenFalse;

  /// Feedback banner heading for a correct answer.
  ///
  /// In en, this message translates to:
  /// **'Nailed it!'**
  String get courseScreenCorrectLabel;

  /// Feedback banner heading for an incorrect answer.
  ///
  /// In en, this message translates to:
  /// **'Not quite.'**
  String get courseScreenIncorrectLabel;

  /// Pill label on fill-in-the-blank questions.
  ///
  /// In en, this message translates to:
  /// **'Fill the Blanks'**
  String get courseScreenFillBlanks;

  /// Hero tagline on the auth screen.
  ///
  /// In en, this message translates to:
  /// **'Learn anything. Master everything.'**
  String get authHeroTagline;

  /// Sign in/up primary action button.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get authSignInButton;

  /// Placeholder for name input.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get authPlaceholderName;

  /// Placeholder for email input.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authPlaceholderEmail;

  /// Validation message for invalid email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authValidationEmail;

  /// Validation message for short password.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authValidationPassword;

  /// Validation message for missing name.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get authValidationName;

  /// Bottom nav label for courses tab.
  ///
  /// In en, this message translates to:
  /// **'My courses'**
  String get navMyCourses;

  /// Bottom nav label for course creation tab.
  ///
  /// In en, this message translates to:
  /// **'Craft course'**
  String get navCraftCourse;

  /// Bottom nav label for profile tab.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get navMyProfile;

  /// Progress label on unit list header.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} units complete'**
  String courseUnitsUnitsComplete(int completed, int total);

  /// Progress section label on unit list.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get courseUnitsProgressSectionLabel;

  /// Learning path section label on unit list.
  ///
  /// In en, this message translates to:
  /// **'YOUR LEARNING PATH'**
  String get courseUnitsLearningPathLabel;

  /// Pill label on concept cards.
  ///
  /// In en, this message translates to:
  /// **'CONCEPT'**
  String get conceptCardLabel;

  /// Back button label on unit list screen.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get courseUnitsBackLabel;

  /// Title for the expertise level picker.
  ///
  /// In en, this message translates to:
  /// **'Expertise level'**
  String get craftExpertiseTitle;

  /// Subtitle for the expertise level picker.
  ///
  /// In en, this message translates to:
  /// **'Sets the depth and rigor of the course content.'**
  String get craftExpertiseSubtitle;

  /// Beginner end label on expertise picker.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get craftExpertiseLabelBeginner;

  /// Expert end label on expertise picker.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get craftExpertiseLabelExpert;

  /// Expertise level 1 description.
  ///
  /// In en, this message translates to:
  /// **'First contact with the topic. No prior knowledge assumed. Simple language and clear analogies.'**
  String get craftExpertiseDescription1;

  /// Expertise level 2 description.
  ///
  /// In en, this message translates to:
  /// **'Introductory awareness. Reinforces fundamentals with clear explanations.'**
  String get craftExpertiseDescription2;

  /// Expertise level 3 description.
  ///
  /// In en, this message translates to:
  /// **'Comfortable with the basics. The course deepens and broadens your understanding.'**
  String get craftExpertiseDescription3;

  /// Expertise level 4 description.
  ///
  /// In en, this message translates to:
  /// **'Significant knowledge. Advanced rigor and professional-level depth.'**
  String get craftExpertiseDescription4;

  /// Expertise level 5 description.
  ///
  /// In en, this message translates to:
  /// **'Expert level. Maximum academic depth and rigor to test the edges of the field.'**
  String get craftExpertiseDescription5;

  /// Job progress banner: queued state label.
  ///
  /// In en, this message translates to:
  /// **'Queued…'**
  String get craftCourseGeneratingQueued;

  /// Job progress banner: processing state label.
  ///
  /// In en, this message translates to:
  /// **'Generating course…'**
  String get craftCourseGeneratingProcessing;

  /// Job progress banner: completed state label.
  ///
  /// In en, this message translates to:
  /// **'Course ready!'**
  String get craftCourseGeneratingCompleted;

  /// Job progress banner: failed state label.
  ///
  /// In en, this message translates to:
  /// **'Generation failed'**
  String get craftCourseGeneratingFailed;

  /// Job progress banner: timeout state label.
  ///
  /// In en, this message translates to:
  /// **'Generation timed out'**
  String get craftCourseGeneratingTimeout;

  /// Job progress banner subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when it\'s done — feel free to leave this screen.'**
  String get craftCourseGeneratingSubtitle;

  /// Badge label on repaso intro screen.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get repasoIntroBadge;

  /// Heading on repaso intro screen.
  ///
  /// In en, this message translates to:
  /// **'Great work!\nJust a few points to revisit.'**
  String get repasoIntroHeading;

  /// Body text on repaso intro screen.
  ///
  /// In en, this message translates to:
  /// **'Let\'s reinforce what matters before we wrap up.'**
  String get repasoIntroBody;

  /// CTA button label on repaso intro screen.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get repasoIntroCta;

  /// Question count label on repaso intro screen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question to review} other{{count} questions to review}}'**
  String repasoIntroQuestionCount(int count);

  /// Heading in the unit completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Unit Complete!'**
  String get unitCompletionHeading;

  /// Body in the unit completion dialog.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do next?'**
  String get unitCompletionBody;

  /// Review button in unit completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get unitCompletionReview;

  /// Repeat button in unit completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Repeat Unit'**
  String get unitCompletionRepeat;

  /// Exit button in unit completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get unitCompletionExit;

  /// Header label during answer review mode.
  ///
  /// In en, this message translates to:
  /// **'Reviewing {current} / {total}'**
  String unitReviewLabel(int current, int total);

  /// Heading of the already-completed unit dialog.
  ///
  /// In en, this message translates to:
  /// **'Unit Completed'**
  String get unitAlreadyCompletedHeading;

  /// Body of the already-completed unit dialog.
  ///
  /// In en, this message translates to:
  /// **'Would you like to repeat this unit from the beginning?'**
  String get unitAlreadyCompletedBody;

  /// Heading in the course completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get courseCompletionHeading;

  /// Subtitle in the course completion dialog.
  ///
  /// In en, this message translates to:
  /// **'You completed the entire course'**
  String get courseCompletionSubtitle;

  /// Body in the course completion dialog.
  ///
  /// In en, this message translates to:
  /// **'You mastered every topic from start to finish. Now that\'s dedication.'**
  String get courseCompletionBody;

  /// CTA button in the course completion dialog.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get courseCompletionCta;

  /// Username field label on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileNameLabel;

  /// New username field label on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get profileNewNameLabel;

  /// Language field label on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageFieldLabel;

  /// Password field label on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profilePasswordLabel;

  /// Password field hint on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep the current password'**
  String get profilePasswordHint;

  /// Save button on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveAction;

  /// Cancel button on profile edit screen.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancelAction;

  /// Snackbar when profile is saved successfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileSavedMessage;

  /// Snackbar when language change requires restart.
  ///
  /// In en, this message translates to:
  /// **'Restart the application to see the language changes.'**
  String get profileRestartLanguageMessage;

  /// Combined snackbar when profile saved with language change.
  ///
  /// In en, this message translates to:
  /// **'Profile updated. Restart the application to see the language changes.'**
  String get profileSavedRestartLanguageMessage;

  /// Validation message for empty username on profile edit.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get profileNameRequired;

  /// Error snackbar when profile update fails.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile: {error}'**
  String profileUpdateFailed(String error);

  /// Sublabel for total courses stat on profile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{course in total} other{courses in total}}'**
  String profileCoursesTotalSublabel(int count);

  /// Sublabel for completed courses stat on profile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{course completed} other{courses completed}}'**
  String profileCoursesCompletedSublabel(int count);

  /// Sublabel for active courses stat on profile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{course active} other{courses active}}'**
  String profileCoursesActiveSublabel(int count);

  /// Sign out button label on profile screen.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;
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
