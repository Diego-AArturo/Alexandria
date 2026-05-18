import 'package:alexandria_movil/components/concept_card.dart';
import 'package:alexandria_movil/components/questions_components/fill_blank_card.dart';
import 'package:alexandria_movil/components/questions_components/mul_choice_card.dart';
import 'package:alexandria_movil/components/questions_components/true_false_card.dart';
import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/progress_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:flutter/material.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({
    super.key,
    required this.courseId,
    required this.courseData,
    required this.unitIndex,
    required this.totalUnits,
  });

  final int courseId;
  final CourseGenerationResponse courseData;
  final int unitIndex; // 0-based
  final int totalUnits;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late String _unitTitle;
  late List<_LessonItem> _items;

  final _progressService = ProgressService();

  final Map<String, _QuestionItem> _retryQuestionById = {};
  bool _retryPhase = false;
  int? _retryPhaseStartIndex;
  int _retryPhaseLength = 0;
  final Set<String> _failedQuestionIdsInPhase = {};
  final Set<String> _countedQuestionIds = {};
  final Set<String> _completedConceptIds = {};
  late Map<String, int> _questionOrder;
  late Map<String, int> _conceptOrder;
  int _baseQuestionCount = 0;
  int _baseConceptCount = 0;
  double _baselineCompletion = 0;
  int _baselineCurrentUnit = 1;

  int _currentIndex = 0;
  String? _selectedOption;
  List<String> _selectedFillAnswers = const [];
  bool _showResult = false;
  bool _initialized = false;
  late AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
    if (!_initialized) {
      _unitTitle = _extractUnitTitle(l10n, widget.courseData, widget.unitIndex);
      _items = _buildItemsForUnit(
        l10n,
        widget.courseData,
        widget.unitIndex,
        _unitTitle,
      );
      _questionOrder = {};
      _conceptOrder = {};
      _baseQuestionCount = 0;
      _baseConceptCount = 0;
      for (final item in _items) {
        if (item.type == _LessonType.concept) {
          _baseConceptCount += 1;
          _conceptOrder[item.conceptKey] = _baseConceptCount;
        } else if (item.question != null) {
          _baseQuestionCount += 1;
          _questionOrder[item.question!.id] = _baseQuestionCount;
        }
      }
      _loadBaselineProgress();
      _initialized = true;
    }
  }

  _LessonItem get _currentItem => _items[_currentIndex];

  int get _totalConcepts =>
      _baseConceptCount;
  int get _totalQuestions =>
      _baseQuestionCount;
  int get _totalTrackable =>
      _baseConceptCount + _baseQuestionCount;
  int get _completedTrackable =>
      _completedConceptIds.length + _countedQuestionIds.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress =
        _totalTrackable == 0 ? 0.0 : _completedTrackable / _totalTrackable;
    final headerSubtitle = _currentItem.type == _LessonType.concept
        ? l10n.courseScreenConceptCounter(
            _conceptPosition(),
            _totalConcepts,
          )
        : (_isInRetryPhase()
            ? l10n.courseScreenRetryCounter(
                _retryPosition(),
                _retryPhaseLength,
              )
            : l10n.courseScreenQuestionCounter(
                _questionPosition(),
                _totalQuestions,
              ));
    final isQuestion = _currentItem.type == _LessonType.question;
    final primaryLabel = isQuestion
        ? (_showResult
            ? l10n.courseScreenContinue
            : l10n.courseScreenSubmitAnswer)
        : l10n.courseScreenContinue;
    final canGoBack = _currentIndex > 0;
    final isRevealedIncorrect = _showResult &&
        _currentItem.type == _LessonType.question &&
        !_isCurrentAnswerCorrect();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFECE7F7),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFECE7F7),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF3D2E66),
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              headerSubtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6B5E8C),
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _unitTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1235),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: const Color(0xFFE0E7FF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildCurrentContent(theme),
              ),
            ),
            if (_showResult && _currentItem.type == _LessonType.question)
              _buildFeedbackBanner(),
            ColoredBox(
              color: (_showResult && _currentItem.type == _LessonType.question)
                  ? (_isCurrentAnswerCorrect()
                      ? const Color(0xFFE2D6FF)
                      : const Color(0xFFFFE4E0))
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: canGoBack ? _prev : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: AppColors.white,
                          textStyle: AppTextStyles.titleMediumBold(theme),
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? AppColors.accentPurple.withValues(alpha: 0.6)
                                : isRevealedIncorrect
                                    ? const Color(0xFFFF5A4E)
                                    : AppColors.primary,
                          ),
                          side: WidgetStateProperty.resolveWith(
                            (states) => const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 9,
                      child: ElevatedButton(
                        onPressed: _primaryEnabled() ? _handlePrimary : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.deepPurple,
                          foregroundColor: AppColors.white,
                          textStyle: AppTextStyles.titleMediumBold(theme),
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? AppColors.accentPurple.withValues(alpha: 1)
                                : isRevealedIncorrect
                                    ? const Color(0xFFFF5A4E)
                                    : AppColors.primary,
                          ),
                        ),
                        child: Text(primaryLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner() {
    final isCorrect = _isCurrentAnswerCorrect();
    final q = _currentItem.question!;
    final explanation =
        isCorrect ? q.explanationCorrect : q.explanationIncorrect;
    final bg = isCorrect ? const Color(0xFFE2D6FF) : const Color(0xFFFFE4E0);
    final topBorderColor =
        isCorrect ? const Color(0xFF5F2FE2) : const Color(0xFFFF5A4E);
    final circleColor =
        isCorrect ? const Color(0xFF5F2FE2) : const Color(0xFFFF5A4E);
    final shadowColor =
        isCorrect ? const Color(0xFF4D14B8) : const Color(0xFFC72A38);
    final textColor =
        isCorrect ? const Color(0xFF4D14B8) : const Color(0xFFC72A38);
    final heading = isCorrect
        ? l10n.courseScreenCorrectLabel
        : l10n.courseScreenIncorrectLabel;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: topBorderColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                heading,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(
              explanation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentContent(ThemeData theme) {
    if (_items.isEmpty) {
      return Text(
        l10n.courseScreenNoContent,
        style: AppTextStyles.bodyMediumMuted(theme, alpha: 0.7),
      );
    }

    if (_currentItem.type == _LessonType.concept) {
      return ConceptCard(
        title: _currentItem.conceptTitle,
        body: _currentItem.conceptBody ?? '',
        bulletPoints: _currentItem.conceptBullets ?? const [],
      );
    }

    final q = _currentItem.question!;
    switch (q.type) {
      case QuestionType.multipleChoice:
        return MulChoiceCard(
          stem: q.stem,
          options: q.options,
          initialSelection: _selectedOption,
          correctAnswer: q.answer,
          explanationCorrect: q.explanationCorrect,
          explanationIncorrect: q.explanationIncorrect,
          onOptionSelected: _onSelectOption,
          showResult: _showResult,
        );
      case QuestionType.trueFalse:
        return TrueFalseCard(
          stem: q.stem,
          initialSelection: _selectedOption,
          correctAnswer: q.answer,
          explanationCorrect: q.explanationCorrect,
          explanationIncorrect: q.explanationIncorrect,
          onAnswerSelected: _onSelectOption,
          showResult: _showResult,
        );
      case QuestionType.fillInBlank:
        return FillBlankCard(
          stem: q.stem,
          options: q.options,
          initialSelections: _selectedFillAnswers,
          correctAnswers: q.answers,
          explanationCorrect: q.explanationCorrect,
          explanationIncorrect: q.explanationIncorrect,
          onSelectionChanged: _onFillSelectionChanged,
          showResult: _showResult,
        );
    }
  }

  bool _primaryEnabled() {
    if (_items.isEmpty) return false;
    if (_currentItem.type == _LessonType.concept) return true;
    if (_showResult) return true;
    return _hasCurrentAnswerSelection();
  }

  void _onSelectOption(String option) {
    if (_showResult) return;
    setState(() {
      _selectedOption = option;
      _showResult = false;
    });
  }

  void _onFillSelectionChanged(List<String> selections) {
    if (_showResult) return;
    setState(() {
      _selectedFillAnswers = selections;
      _showResult = false;
    });
  }

  Future<void> _handlePrimary() async {
    if (_items.isEmpty) return;

    if (_currentItem.type == _LessonType.concept) {
      _markConceptCompleted();
      await _persistProgress();
      _next();
      return;
    }

    if (!_showResult) {
      if (!_hasCurrentAnswerSelection()) return;
      setState(() {
        _showResult = true;
      });
      if (!_isCurrentAnswerCorrect()) {
        _queueCurrentQuestionForRetry();
        _markQuestionFailedInPhase();
      }
      await _persistProgress();
      return;
    }

    if (_isCurrentAnswerCorrect()) {
      _markQuestionCompletedIfEligible();
    }
    await _persistProgress();
    _next();
  }

  void _next() {
    if (_currentIndex >= _items.length - 1) {
      if (_retryQuestionById.isNotEmpty) {
        final retryItems = _retryQuestionById.values
            .map((q) => _LessonItem.question(question: q))
            .toList(growable: false);
        final startIndex = _items.length;
        setState(() {
          _items.addAll(retryItems);
          _failedQuestionIdsInPhase.removeAll(_retryQuestionById.keys);
          _retryQuestionById.clear();
          _retryPhase = true;
          _retryPhaseStartIndex = startIndex;
          _retryPhaseLength = retryItems.length;
          _currentIndex += 1;
          _selectedOption = null;
          _selectedFillAnswers = const [];
          _showResult = false;
        });
        return;
      }
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _currentIndex += 1;
      _selectedOption = null;
      _selectedFillAnswers = const [];
      _showResult = false;
    });
  }

  void _prev() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex -= 1;
      _selectedOption = null;
      _selectedFillAnswers = const [];
      _showResult = false;
    });
  }

  int _conceptPosition() {
    if (_currentItem.type != _LessonType.concept) return 0;
    return _conceptOrder[_currentItem.conceptKey] ?? 0;
  }

  int _questionPosition() {
    if (_currentItem.type != _LessonType.question) return 0;
    return _questionOrder[_currentItem.question!.id] ?? 0;
  }

  Future<void> _persistProgress() async {
    final isFinalItem = _currentIndex >= _items.length - 1;
    var nextUnit = widget.unitIndex + 1;
    if (isFinalItem) {
      nextUnit = (widget.unitIndex + 2).clamp(1, widget.totalUnits);
    }

    final isConcept = _currentItem.type == _LessonType.concept;
    final conceptPos = _conceptPosition();
    final questionPos = _questionPosition();
    final unitProgress =
        _totalTrackable == 0 ? 0.0 : _completedTrackable / _totalTrackable;
    final courseProgress =
        ((widget.unitIndex + unitProgress) / widget.totalUnits * 100).clamp(0, 100).toDouble();

    final resolvedUserId = Session.userId ?? 0;
    final resolvedCurrentUnit =
        nextUnit < _baselineCurrentUnit ? _baselineCurrentUnit : nextUnit;
    final resolvedCompletion =
        courseProgress < _baselineCompletion ? _baselineCompletion : courseProgress;

    final payload = ProgressPayload(
      userId: resolvedUserId,
      courseId: widget.courseId,
      currentUnit: resolvedCurrentUnit,
      currentConcept: isConcept ? conceptPos : conceptPos,
      currentQuestion: isConcept ? questionPos : questionPos,
      completionPercentage: resolvedCompletion,
    );

    try {
      await _progressService.saveProgress(payload);
      _baselineCurrentUnit = resolvedCurrentUnit;
      _baselineCompletion = resolvedCompletion;
    } catch (_) {
      // Silently ignore for now; could show a toast if desired.
    }
  }

  String? _normalizeAnswer(String? value) {
    return value?.trim().toLowerCase();
  }

  int _blankCount(String stem) {
    return RegExp(r'_{3,}').allMatches(stem).length;
  }

  bool _isCompactMultiBlank(String stem) {
    final matches = RegExp(r'_{3,}').allMatches(stem).toList(growable: false);
    if (matches.length <= 1) return false;
    for (var i = 0; i < matches.length - 1; i++) {
      final gap = matches[i + 1].start - matches[i].end;
      if (gap >= 7) {
        return false;
      }
    }
    return true;
  }

  List<String> _normalizeAnswers(Iterable<String> values) {
    return values
        .map((v) => v.trim().toLowerCase())
        .where((v) => v.isNotEmpty)
        .toList(growable: false);
  }

  bool _hasCurrentAnswerSelection() {
    if (_currentItem.type != _LessonType.question) return false;
    final q = _currentItem.question!;
    if (q.type != QuestionType.fillInBlank) {
      return _selectedOption != null;
    }

    final blanks = _blankCount(q.stem);
    if (blanks > 1) {
      if (_selectedFillAnswers.isEmpty) return false;
      return _selectedFillAnswers
          .take(blanks)
          .any((value) => value.trim().isNotEmpty);
    }

    return _normalizeAnswers(_selectedFillAnswers).isNotEmpty;
  }

  bool _isCurrentAnswerCorrect() {
    if (_currentItem.type != _LessonType.question) return true;
    final q = _currentItem.question!;
    if (q.type != QuestionType.fillInBlank) {
      if (_selectedOption == null) return false;
      return _normalizeAnswer(_selectedOption) == _normalizeAnswer(q.answer);
    }

    final expected = _normalizeAnswers(q.answers);
    if (expected.isEmpty) return false;

    final blanks = _blankCount(q.stem);
    if (blanks > 1) {
      if (expected.length != blanks || _selectedFillAnswers.length < blanks) {
        return false;
      }
      final selectedOrdered = _selectedFillAnswers
          .take(blanks)
          .map((value) => value.trim().toLowerCase())
          .toList(growable: false);
      if (selectedOrdered.any((value) => value.isEmpty)) return false;
      if (_isCompactMultiBlank(q.stem)) {
        final sortedExpected = List<String>.from(expected)..sort();
        final sortedSelected = List<String>.from(selectedOrdered)..sort();
        for (var i = 0; i < blanks; i++) {
          if (sortedSelected[i] != sortedExpected[i]) return false;
        }
        return true;
      }
      for (var i = 0; i < blanks; i++) {
        if (selectedOrdered[i] != expected[i]) return false;
      }
      return true;
    }

    final selected = _normalizeAnswers(_selectedFillAnswers);
    if (expected.length > 1) {
      if (selected.length != expected.length) return false;
      final sortedExpected = List<String>.from(expected)..sort();
      final sortedSelected = List<String>.from(selected)..sort();
      for (var i = 0; i < sortedExpected.length; i++) {
        if (sortedExpected[i] != sortedSelected[i]) return false;
      }
      return true;
    }

    if (selected.isEmpty) return false;
    return selected.first == expected.first;
  }

  String _questionKey(_QuestionItem question) {
    return question.id;
  }

  void _queueCurrentQuestionForRetry() {
    if (_currentItem.type != _LessonType.question) return;
    final question = _currentItem.question!;
    _retryQuestionById.putIfAbsent(_questionKey(question), () => question);
  }

  void _markQuestionFailedInPhase() {
    if (_currentItem.type != _LessonType.question) return;
    _failedQuestionIdsInPhase.add(_currentItem.question!.id);
  }

  void _markQuestionCompletedIfEligible() {
    if (_currentItem.type != _LessonType.question) return;
    final id = _currentItem.question!.id;
    if (_failedQuestionIdsInPhase.contains(id)) return;
    _countedQuestionIds.add(id);
  }

  void _markConceptCompleted() {
    if (_currentItem.type != _LessonType.concept) return;
    _completedConceptIds.add(_currentItem.conceptKey);
  }

  Future<void> _loadBaselineProgress() async {
    final userId = Session.userId;
    if (userId == null || userId == 0) return;
    try {
      final progress = await _progressService.fetchProgress(
        userId: userId,
        courseId: widget.courseId,
      );
      if (!mounted) return;
      setState(() {
        _baselineCurrentUnit = progress.currentUnit == 0 ? 1 : progress.currentUnit;
        _baselineCompletion = progress.completionPercentage;
      });
    } catch (_) {
      // Ignore missing/failed progress fetch.
    }
  }

  bool _isInRetryPhase() {
    if (!_retryPhase) return false;
    if (_retryPhaseStartIndex == null) return false;
    return _currentIndex >= _retryPhaseStartIndex!;
  }

  int _retryPosition() {
    if (!_isInRetryPhase()) return 0;
    return (_currentIndex - _retryPhaseStartIndex!) + 1;
  }
}

enum _LessonType { concept, question }

class _LessonItem {
  const _LessonItem.concept({
    required this.conceptKey,
    required this.conceptTitle,
    required this.conceptBody,
    this.conceptBullets,
  })  : type = _LessonType.concept,
        question = null;

  const _LessonItem.question({
    required this.question,
  })  : type = _LessonType.question,
        conceptKey = '',
        conceptTitle = null,
        conceptBody = null,
        conceptBullets = null;

  final _LessonType type;
  final String conceptKey;

  // Concept
  final String? conceptTitle;
  final String? conceptBody;
  final List<String>? conceptBullets;

  // Question
  final _QuestionItem? question;
}

enum QuestionType { multipleChoice, trueFalse, fillInBlank }

class _QuestionItem {
  const _QuestionItem({
    required this.id,
    required this.type,
    required this.stem,
    required this.options,
    required this.answer,
    required this.answers,
    required this.explanationCorrect,
    required this.explanationIncorrect,
  });

  final String id;
  final QuestionType type;
  final String stem;
  final List<String> options;
  final String answer;
  final List<String> answers;
  final String explanationCorrect;
  final String explanationIncorrect;
}

String _extractUnitTitle(
  AppLocalizations l10n,
  CourseGenerationResponse data,
  int index,
) {
  final units = (data.units['units'] as List?)?.cast<Map>() ?? const [];
  if (index < units.length) {
    final raw = Map<String, dynamic>.from(units[index]);
    return raw['unit_title']?.toString().isNotEmpty == true
        ? raw['unit_title'].toString()
        : l10n.unitNumberLabel(index + 1);
  }
  return l10n.unitNumberLabel(index + 1);
}

List<_LessonItem> _buildItemsForUnit(
  AppLocalizations l10n,
  CourseGenerationResponse data,
  int unitIndex,
  String unitTitle,
) {
  final items = <_LessonItem>[];
  var conceptIndex = 0;

  // Concepts
  final concepts = _extractConceptsForUnit(data.concepts, unitTitle);
  for (var i = 0; i < concepts.length; i++) {
    final concept = concepts[i];
    conceptIndex += 1;
    items.add(
      _LessonItem.concept(
        conceptKey: 'c$conceptIndex',
        conceptTitle: (concept.title?.isNotEmpty ?? false) ? concept.title : unitTitle,
        conceptBody: concept.body,
        conceptBullets: concept.bullets,
      ),
    );
  }

  // Questions
  final questions = _extractQuestionsForUnit(data.questions, unitTitle);
  for (final q in questions) {
    items.add(_LessonItem.question(question: q));
  }

  if (items.isEmpty) {
    items.add(
      _LessonItem.concept(
        conceptKey: 'c${conceptIndex + 1}',
        conceptTitle: unitTitle,
        conceptBody: l10n.courseScreenPlaceholderContent,
        conceptBullets: const [],
      ),
    );
  }

  return items;
}

class _ConceptParsed {
  const _ConceptParsed({this.title, required this.body, this.bullets});
  final String? title;
  final String body;
  final List<String>? bullets;
}

List<_ConceptParsed> _extractConceptsForUnit(
  List<Map<String, dynamic>> conceptsPayload,
  String unitTitle,
) {
  // Payload shape is likely [{ "units": [{ "unit_title": "...", "concepts": [str] }] }, ...]
  final list = <_ConceptParsed>[];
  for (final item in conceptsPayload) {
    final units = item['units'];
    if (units is List && units.isNotEmpty) {
      for (final u in units) {
        final unitMap = Map<String, dynamic>.from(u as Map);
        final title = unitMap['unit_title']?.toString() ?? '';
        if (title.toLowerCase() != unitTitle.toLowerCase()) continue;
        final conceptList = unitMap['concepts'] as List?;
        if (conceptList != null) {
          for (final c in conceptList) {
            if (c is Map) {
              final conceptMap = Map<String, dynamic>.from(c);
              final body = conceptMap['body']?.toString() ??
                  conceptMap['text']?.toString() ??
                  conceptMap['concept']?.toString() ??
                  '';
              if (body.isEmpty) continue;
              final maybeTitle = conceptMap['title']?.toString();
              final bullets = (conceptMap['bullets'] as List?)
                      ?.map((e) => e.toString())
                      .toList(growable: false) ??
                  const <String>[];
              list.add(
                _ConceptParsed(
                  title: (maybeTitle?.isEmpty ?? true) ? null : maybeTitle,
                  body: body,
                  bullets: bullets.isEmpty ? null : bullets,
                ),
              );
            } else {
              final body = c.toString();
              list.add(_ConceptParsed(body: body));
            }
          }
        }
      }
    } else if (item['unit_title'] != null &&
        item['unit_title'].toString().toLowerCase() ==
            unitTitle.toLowerCase()) {
      final conceptList = item['concepts'] as List?;
      if (conceptList != null) {
        for (final c in conceptList) {
          if (c is Map) {
            final conceptMap = Map<String, dynamic>.from(c);
            final body = conceptMap['body']?.toString() ??
                conceptMap['text']?.toString() ??
                conceptMap['concept']?.toString() ??
                '';
            if (body.isEmpty) continue;
            final maybeTitle = conceptMap['title']?.toString();
            final bullets = (conceptMap['bullets'] as List?)
                    ?.map((e) => e.toString())
                    .toList(growable: false) ??
                const <String>[];
            list.add(
              _ConceptParsed(
                title: (maybeTitle?.isEmpty ?? true) ? null : maybeTitle,
                body: body,
                bullets: bullets.isEmpty ? null : bullets,
              ),
            );
          } else {
            list.add(_ConceptParsed(body: c.toString()));
          }
        }
      }
    }
  }
  return list;
}

List<_QuestionItem> _extractQuestionsForUnit(
  List<Map<String, dynamic>> questionsPayload,
  String unitTitle,
) {
  final result = <_QuestionItem>[];
  var index = 0;
  for (final block in questionsPayload) {
    final units = block['units'];
    if (units is List && units.isNotEmpty) {
      for (final u in units) {
        final unitMap = Map<String, dynamic>.from(u as Map);
        final title = unitMap['unit_title']?.toString() ?? '';
        if (title.toLowerCase() != unitTitle.toLowerCase()) continue;
        final qList = unitMap['questions'] as List?;
        if (qList != null) {
          final mapped = _mapQuestions(qList, index);
          index += mapped.length;
          result.addAll(mapped);
        }
      }
    } else if (block['unit_title'] != null &&
        block['unit_title'].toString().toLowerCase() ==
            unitTitle.toLowerCase()) {
      final qList = block['questions'] as List?;
      if (qList != null) {
        final mapped = _mapQuestions(qList, index);
        index += mapped.length;
        result.addAll(mapped);
      }
    }
  }
  return result;
}

List<_QuestionItem> _mapQuestions(List<dynamic> rawQuestions, int startIndex) {
  return rawQuestions.asMap().entries.map((entry) {
    final idx = entry.key + startIndex;
    final q = entry.value;
    final map = Map<String, dynamic>.from(q as Map);
    final typeStr = map['type']?.toString() ?? 'multiple_choice';
    final type = switch (typeStr) {
      'multiple_choice' => QuestionType.multipleChoice,
      'true_false' => QuestionType.trueFalse,
      'fill_in_blank' => QuestionType.fillInBlank,
      _ => QuestionType.multipleChoice,
    };
    final optionsList = (map['options'] as List?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        <String>[];
    final answers = _parseAnswerValues(map['answer'], type);

    return _QuestionItem(
      id: 'q$idx',
      type: type,
      stem: map['stem']?.toString() ?? '',
      options: optionsList,
      answer: answers.isEmpty ? '' : answers.first,
      answers: answers,
      explanationCorrect: map['explanation_correct']?.toString() ?? '',
      explanationIncorrect: map['explanation_incorrect']?.toString() ?? '',
    );
  }).toList();
}

List<String> _parseAnswerValues(dynamic rawAnswer, QuestionType type) {
  if (rawAnswer == null) return const <String>[];

  if (rawAnswer is List) {
    return rawAnswer
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  final rawString = rawAnswer.toString().trim();
  if (rawString.isEmpty) return const <String>[];

  if (type == QuestionType.fillInBlank && rawString.contains(',')) {
    return rawString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  return <String>[rawString];
}
