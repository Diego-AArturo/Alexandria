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

  int _currentIndex = 0;
  String? _selectedOption;
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
      _initialized = true;
    }
  }

  _LessonItem get _currentItem => _items[_currentIndex];

  int get _totalConcepts =>
      _items.where((item) => item.type == _LessonType.concept).length;
  int get _totalQuestions =>
      _items.where((item) => item.type == _LessonType.question).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentIndex + 1) / (_items.isEmpty ? 1 : _items.length);
    final headerSubtitle = _currentItem.type == _LessonType.concept
        ? l10n.courseScreenConceptCounter(
            _conceptPosition(),
            _totalConcepts,
          )
        : l10n.courseScreenQuestionCounter(
            _questionPosition(),
            _totalQuestions,
          );
    final isQuestion = _currentItem.type == _LessonType.question;
    final primaryLabel = isQuestion
        ? (_showResult ? l10n.courseScreenContinue : l10n.courseScreenSubmitAnswer)
        : l10n.courseScreenContinue;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _unitTitle,
                          style: AppTextStyles.titleMediumBold(theme),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          headerSubtitle,
                          style: AppTextStyles.bodyMediumMuted(theme, alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: theme.dividerColor),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildCurrentContent(theme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _primaryEnabled() ? _handlePrimary : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.deepPurple,
                    foregroundColor: AppColors.white,
                    textStyle: AppTextStyles.titleMediumBold(theme),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.disabled)
                          ? AppColors.accentPurple.withValues(alpha: 0.6)
                          : AppColors.deepPurple,
                    ),
                  ),
                  child: Text(primaryLabel),
                ),
              ),
            ),
          ],
        ),
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
        title: _currentItem.conceptTitle ?? _unitTitle,
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
          initialSelection: _selectedOption,
          correctAnswer: q.answer,
          explanationCorrect: q.explanationCorrect,
          explanationIncorrect: q.explanationIncorrect,
          onOptionSelected: _onSelectOption,
          showResult: _showResult,
        );
    }
  }

  bool _primaryEnabled() {
    if (_items.isEmpty) return false;
    if (_currentItem.type == _LessonType.concept) return true;
    if (!_showResult) {
      return _selectedOption != null;
    }
    return true;
  }

  void _onSelectOption(String option) {
    setState(() {
      _selectedOption = option;
      _showResult = false;
    });
  }

  Future<void> _handlePrimary() async {
    if (_items.isEmpty) return;

    if (_currentItem.type == _LessonType.concept) {
      await _persistProgress();
      _next();
      return;
    }

    if (!_showResult) {
      if (_selectedOption == null) return;
      setState(() {
        _showResult = true;
      });
      await _persistProgress();
      return;
    }

    await _persistProgress();
    _next();
  }

  void _next() {
    if (_currentIndex >= _items.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _currentIndex += 1;
      _selectedOption = null;
      _showResult = false;
    });
  }

  int _conceptPosition() {
    var count = 0;
    for (var i = 0; i <= _currentIndex; i++) {
      if (_items[i].type == _LessonType.concept) count++;
    }
    return count;
  }

  int _questionPosition() {
    var count = 0;
    for (var i = 0; i <= _currentIndex; i++) {
      if (_items[i].type == _LessonType.question) count++;
    }
    return count;
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
    final unitProgress = (_currentIndex + 1) / (_items.isEmpty ? 1 : _items.length);
    final courseProgress =
        ((widget.unitIndex + unitProgress) / widget.totalUnits * 100).clamp(0, 100).toDouble();

    final payload = ProgressPayload(
      userId: Session.userId ?? 0,
      courseId: widget.courseId,
      currentUnit: nextUnit,
      currentConcept: isConcept ? conceptPos : conceptPos,
      currentQuestion: isConcept ? questionPos : questionPos,
      completionPercentage: courseProgress,
    );

    try {
      await _progressService.saveProgress(payload);
    } catch (_) {
      // Silently ignore for now; could show a toast if desired.
    }
  }
}

enum _LessonType { concept, question }

class _LessonItem {
  const _LessonItem.concept({
    required this.conceptTitle,
    required this.conceptBody,
    this.conceptBullets,
  })  : type = _LessonType.concept,
        question = null;

  const _LessonItem.question({
    required this.question,
  })  : type = _LessonType.question,
        conceptTitle = null,
        conceptBody = null,
        conceptBullets = null;

  final _LessonType type;

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
    required this.type,
    required this.stem,
    required this.options,
    required this.answer,
    required this.explanationCorrect,
    required this.explanationIncorrect,
  });

  final QuestionType type;
  final String stem;
  final List<String> options;
  final String answer;
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

  // Concepts
  final concepts = _extractConceptsForUnit(data.concepts, unitTitle);
  for (var i = 0; i < concepts.length; i++) {
    final concept = concepts[i];
    items.add(
      _LessonItem.concept(
        conceptTitle: concept.title ??
            l10n.courseScreenFallbackConceptTitle(
              unitTitle,
              i + 1,
            ),
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
  for (final block in questionsPayload) {
    final units = block['units'];
    if (units is List && units.isNotEmpty) {
      for (final u in units) {
        final unitMap = Map<String, dynamic>.from(u as Map);
        final title = unitMap['unit_title']?.toString() ?? '';
        if (title.toLowerCase() != unitTitle.toLowerCase()) continue;
        final qList = unitMap['questions'] as List?;
        if (qList != null) {
          result.addAll(_mapQuestions(qList));
        }
      }
    } else if (block['unit_title'] != null &&
        block['unit_title'].toString().toLowerCase() ==
            unitTitle.toLowerCase()) {
      final qList = block['questions'] as List?;
      if (qList != null) {
        result.addAll(_mapQuestions(qList));
      }
    }
  }
  return result;
}

List<_QuestionItem> _mapQuestions(List<dynamic> rawQuestions) {
  return rawQuestions.map((q) {
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

    return _QuestionItem(
      type: type,
      stem: map['stem']?.toString() ?? '',
      options: optionsList,
      answer: map['answer']?.toString() ?? '',
      explanationCorrect: map['explanation_correct']?.toString() ?? '',
      explanationIncorrect: map['explanation_incorrect']?.toString() ?? '',
    );
  }).toList();
}
