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
  String get courseScreenSubmitAnswer => 'Submit Answer';

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
}
