// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authFillRequiredFields => 'Please fill all required fields.';

  @override
  String get authTitleSignIn => 'Sign in';

  @override
  String get authTitleCreateAccount => 'Create account';

  @override
  String get authLabelEmail => 'Email';

  @override
  String get authLabelName => 'Name';

  @override
  String get authLabelPassword => 'Password';

  @override
  String get authPrimaryContinue => 'Continue';

  @override
  String get authPrimaryCreateAccount => 'Create account';

  @override
  String get authGoogleSigningIn => 'Signing in...';

  @override
  String get authGoogleContinue => 'Continue with Google';

  @override
  String get authToggleNoAccount => 'No account? Sign up';

  @override
  String get authToggleHasAccount => 'Already have an account? Sign in';

  @override
  String authSnackbarAuthFailed(String error) {
    return 'Auth failed: $error';
  }

  @override
  String authSnackbarGoogleFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get authErrorGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authErrorGoogleMissingIdToken => 'Missing Google idToken';

  @override
  String get courseHomeSignInPrompt => 'Please sign in to load courses.';

  @override
  String get courseHomeTitle => 'My courses';

  @override
  String courseHomeLoadFailed(String error) {
    return 'Failed to load courses: $error';
  }

  @override
  String get courseHomeEmptyState =>
      'No courses yet. Generate one to get started.';

  @override
  String get courseHomeEmptyMockTitle => 'Create your first course';

  @override
  String get courseHomeEmptyMockDescription =>
      'Use the Craft course tab to describe what you want to learn. Here\'s a sample of how your courses will look.';

  @override
  String get courseHomeEmptyMockSampleTitle =>
      'Example: Python for automating small tasks';

  @override
  String get courseHomeEmptyMockSampleDescription =>
      '3 short units · Beginner friendly · Practical exercises';

  @override
  String get courseHomeEmptyMockAction => 'Go to Craft course';

  @override
  String get courseHomeEmptyMockActionHint =>
      'Open the Craft course tab below to start your first course.';

  @override
  String courseHomeProgressLabel(int percent) {
    return 'Progress $percent%';
  }

  @override
  String unitNumberLabel(int number) {
    return 'Unit $number';
  }

  @override
  String courseUnitsProgressLabel(int percent) {
    return 'Progress $percent%';
  }

  @override
  String courseUnitsCurrentLabel(int current, int total) {
    return 'You are in Unit $current of $total';
  }

  @override
  String courseUnitsLoadFailed(String error) {
    return 'Failed to load progress: $error';
  }

  @override
  String courseScreenConceptCounter(int current, int total) {
    return 'Concept $current of $total';
  }

  @override
  String courseScreenQuestionCounter(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String courseScreenRetryCounter(int current, int total) {
    return 'Refresher $current of $total';
  }

  @override
  String get courseScreenSubmitAnswer => 'Submit Answer';

  @override
  String get courseScreenPrevious => 'Previous';

  @override
  String get courseScreenContinue => 'Continue';

  @override
  String get courseScreenNoContent => 'No content available for this unit.';

  @override
  String get courseScreenPlaceholderContent =>
      'Content for this unit is not available yet.';

  @override
  String courseScreenFallbackConceptTitle(String unitTitle, int number) {
    return '$unitTitle - Concept $number';
  }

  @override
  String get craftCourseTitle => 'Craft a Course';

  @override
  String get craftCourseSubtitle =>
      'Describe what you want to learn and we\'ll create a short, tailored course for you.';

  @override
  String get craftCoursePromptHint =>
      'Example: I want to learn the basics of Python to automate simple tasks.';

  @override
  String get craftCourseSubmitLabel => 'Create Course';

  @override
  String get craftCourseSubmittingLabel => 'Creating...';

  @override
  String get craftCourseToastEmptyPrompt =>
      'Please describe the course you want.';

  @override
  String get craftCourseQueuedMessage =>
      'Course queued. We will notify you when it is ready.';

  @override
  String craftCourseLimitReached(int limit) {
    return 'Beta limit reached: you can create up to $limit courses.';
  }

  @override
  String craftCourseLimitCheckFailed(String error) {
    return 'Could not validate your courses: $error';
  }

  @override
  String craftCourseGenerateFailed(String error) {
    return 'Failed to generate course: $error';
  }

  @override
  String get craftCourseGeneratedTitleFallback => 'Generated course';

  @override
  String get craftCourseGeneratedDescriptionFallback => 'Your generated course';

  @override
  String craftCourseOpenFailed(String error) {
    return 'Course generated but failed to open: $error';
  }

  @override
  String get craftCourseTipsTitle => 'Tips for great courses:';

  @override
  String get craftCourseTipSpecificGoals =>
      'Be specific about your learning goals';

  @override
  String get craftCourseTipKnowledgeLevel =>
      'Mention your current knowledge level';

  @override
  String get craftCourseTipTopics =>
      'Include any specific topics you want covered';

  @override
  String get profileSignInPrompt => 'Please sign in to view your profile.';

  @override
  String profileLoadFailed(String error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileGuestName => 'Guest';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get profileCoursesTitle => 'Courses';

  @override
  String get profileCoursesTotalLabel => 'Total courses';

  @override
  String get profileCompletedTitle => 'Completed';

  @override
  String get profileCoursesCompletedLabel => 'Courses completed';

  @override
  String get profileInProgressTitle => 'In progress';

  @override
  String get profileCoursesActiveLabel => 'Courses currently active';

  @override
  String get profileAccountInfoTitle => 'Account Information';

  @override
  String get courseScreenSelectOne => 'Select one';

  @override
  String get courseScreenTrueOrFalse => 'True or False';

  @override
  String get courseScreenTrue => 'True';

  @override
  String get courseScreenFalse => 'False';

  @override
  String get courseScreenCorrectLabel => 'Nailed it!';

  @override
  String get courseScreenIncorrectLabel => 'Not quite.';

  @override
  String get courseScreenFillBlanks => 'Fill the Blanks';

  @override
  String get authHeroTagline => 'Learn anything. Master everything.';

  @override
  String get authSignInButton => 'Let\'s go!';

  @override
  String get authPlaceholderName => 'Your full name';

  @override
  String get authPlaceholderEmail => 'you@example.com';

  @override
  String get authValidationEmail => 'Enter a valid email';

  @override
  String get authValidationPassword => 'At least 8 characters';

  @override
  String get authValidationName => 'Name is required';

  @override
  String get navMyCourses => 'My courses';

  @override
  String get navCraftCourse => 'Craft course';

  @override
  String get navMyProfile => 'My profile';

  @override
  String courseUnitsUnitsComplete(int completed, int total) {
    return '$completed of $total units complete';
  }

  @override
  String get courseUnitsProgressSectionLabel => 'Progress';

  @override
  String get courseUnitsLearningPathLabel => 'YOUR LEARNING PATH';

  @override
  String get conceptCardLabel => 'CONCEPT';

  @override
  String get courseUnitsBackLabel => 'Back';

  @override
  String get craftExpertiseTitle => 'Expertise level';

  @override
  String get craftExpertiseSubtitle =>
      'Sets the depth and rigor of the course content.';

  @override
  String get craftExpertiseLabelBeginner => 'Beginner';

  @override
  String get craftExpertiseLabelExpert => 'Expert';

  @override
  String get craftExpertiseDescription1 =>
      'First contact with the topic. No prior knowledge assumed. Simple language and clear analogies.';

  @override
  String get craftExpertiseDescription2 =>
      'Introductory awareness. Reinforces fundamentals with clear explanations.';

  @override
  String get craftExpertiseDescription3 =>
      'Comfortable with the basics. The course deepens and broadens your understanding.';

  @override
  String get craftExpertiseDescription4 =>
      'Significant knowledge. Advanced rigor and professional-level depth.';

  @override
  String get craftExpertiseDescription5 =>
      'Expert level. Maximum academic depth and rigor to test the edges of the field.';

  @override
  String get craftCourseGeneratingQueued => 'Queued…';

  @override
  String get craftCourseGeneratingProcessing => 'Generating course…';

  @override
  String get craftCourseGeneratingCompleted => 'Course ready!';

  @override
  String get craftCourseGeneratingFailed => 'Generation failed';

  @override
  String get craftCourseGeneratingTimeout => 'Generation timed out';

  @override
  String get craftCourseGeneratingSubtitle =>
      'We\'ll notify you when it\'s done — feel free to leave this screen.';

  @override
  String get repasoIntroBadge => 'Review';

  @override
  String get repasoIntroHeading => 'Great work!\nJust a few points to revisit.';

  @override
  String get repasoIntroBody =>
      'Let\'s reinforce what matters before we wrap up.';

  @override
  String get repasoIntroCta => 'Let\'s go!';

  @override
  String repasoIntroQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions to review',
      one: '1 question to review',
    );
    return '$_temp0';
  }

  @override
  String get unitCompletionHeading => 'Unit Complete!';

  @override
  String get unitCompletionBody => 'What would you like to do next?';

  @override
  String get unitCompletionReview => 'Review Answers';

  @override
  String get unitCompletionRepeat => 'Repeat Unit';

  @override
  String get unitCompletionExit => 'Exit';

  @override
  String unitReviewLabel(int current, int total) {
    return 'Reviewing $current / $total';
  }

  @override
  String get unitAlreadyCompletedHeading => 'Unit Completed';

  @override
  String get unitAlreadyCompletedBody =>
      'Would you like to repeat this unit from the beginning?';

  @override
  String get courseCompletionHeading => 'Congratulations!';

  @override
  String get courseCompletionSubtitle => 'You completed the entire course';

  @override
  String get courseCompletionBody =>
      'You mastered every topic from start to finish. Now that\'s dedication.';

  @override
  String get courseCompletionCta => 'Continue';

  @override
  String get profileNameLabel => 'Username';

  @override
  String get profileNewNameLabel => 'New username';

  @override
  String get profileLanguageFieldLabel => 'Language';

  @override
  String get profilePasswordLabel => 'New password';

  @override
  String get profilePasswordHint => 'Leave blank to keep the current password';

  @override
  String get profileSaveAction => 'Save';

  @override
  String get profileCancelAction => 'Cancel';

  @override
  String get profileSavedMessage => 'Profile updated';

  @override
  String get profileRestartLanguageMessage =>
      'Restart the application to see the language changes.';

  @override
  String get profileSavedRestartLanguageMessage =>
      'Profile updated. Restart the application to see the language changes.';

  @override
  String get profileNameRequired => 'Username is required';

  @override
  String profileUpdateFailed(String error) {
    return 'Could not update profile: $error';
  }

  @override
  String profileCoursesTotalSublabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'courses in total',
      one: 'course in total',
    );
    return '$_temp0';
  }

  @override
  String profileCoursesCompletedSublabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'courses completed',
      one: 'course completed',
    );
    return '$_temp0';
  }

  @override
  String profileCoursesActiveSublabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'courses active',
      one: 'course active',
    );
    return '$_temp0';
  }

  @override
  String get profileSignOut => 'Sign out';
}
