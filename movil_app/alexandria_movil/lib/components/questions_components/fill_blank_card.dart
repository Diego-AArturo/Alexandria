import 'dart:math';

import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:flutter/material.dart';

class FillBlankCard extends StatefulWidget {
  const FillBlankCard({
    super.key,
    required this.stem,
    required this.options,
    this.initialSelections,
    this.correctAnswers,
    this.explanationCorrect,
    this.explanationIncorrect,
    this.onSelectionChanged,
    this.showResult = false,
  });

  /// Texto con espacio en blanco representado con "___".
  final String stem;

  /// Opciones para rellenar el espacio en blanco.
  final List<String> options;

  /// Selecciones iniciales (si el estado se controla externamente).
  final List<String>? initialSelections;

  /// Respuestas correctas para feedback.
  final List<String>? correctAnswers;

  /// Mensaje para respuesta correcta.
  final String? explanationCorrect;

  /// Mensaje para respuesta incorrecta.
  final String? explanationIncorrect;

  /// Callback cuando el usuario cambia la(s) seleccion(es).
  final ValueChanged<List<String>>? onSelectionChanged;

  /// Si es true, muestra feedback y resalta correcto/incorrecto.
  final bool showResult;

  @override
  State<FillBlankCard> createState() => _FillBlankCardState();
}

class _FillBlankCardState extends State<FillBlankCard> {
  late List<String?> _slotSelections;
  late List<String> _singleSelections;
  late List<String> _shuffledOptions;

  static final RegExp _placeholder = RegExp(r'_{3,}');

  int get _blankCount => _placeholder.allMatches(widget.stem).length;
  bool get _slotMode => _blankCount > 1;
  bool get _unorderedMultiSelect =>
      !_slotMode && (widget.correctAnswers?.length ?? 0) > 1;
  bool get _compactMultiBlank {
    final matches = _placeholder.allMatches(widget.stem).toList(growable: false);
    if (matches.length <= 1) return false;
    for (var i = 0; i < matches.length - 1; i++) {
      final gap = matches[i + 1].start - matches[i].end;
      if (gap >= 7) {
        return false;
      }
    }
    return true;
  }

  List<String> get _normalizedCorrectAnswers => (widget.correctAnswers ?? const [])
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
    _initializeStateFromWidget();
  }

  @override
  void didUpdateWidget(covariant FillBlankCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedInitial = oldWidget.initialSelections != widget.initialSelections;
    final changedStem = oldWidget.stem != widget.stem;
    final changedAnswers = oldWidget.correctAnswers != widget.correctAnswers;
    final changedOptions = oldWidget.options != widget.options;
    if (changedStem || changedOptions) {
      _shuffleOptions();
    }
    if (changedInitial || changedStem || changedAnswers || changedOptions) {
      _initializeStateFromWidget();
    }
  }

  void _shuffleOptions() {
    _shuffledOptions = List<String>.from(widget.options);
    _shuffledOptions.shuffle(Random());
  }

  void _initializeStateFromWidget() {
    if (_slotMode) {
      final initial = widget.initialSelections ?? const <String>[];
      final list = List<String?>.filled(_blankCount, null, growable: false);
      final limit = initial.length < list.length ? initial.length : list.length;
      for (var i = 0; i < limit; i++) {
        final value = initial[i].trim();
        if (value.isNotEmpty) {
          list[i] = value;
        }
      }
      _slotSelections = list;
      _singleSelections = <String>[];
      return;
    }

    _slotSelections = const <String?>[];
    final initial = widget.initialSelections ?? const <String>[];
    if (_unorderedMultiSelect) {
      _singleSelections = initial
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: true);
    } else {
      final first = initial
          .map((value) => value.trim())
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');
      _singleSelections = first.isEmpty ? <String>[] : <String>[first];
    }
  }

  void _emitSelectionChanged() {
    if (_slotMode) {
      widget.onSelectionChanged?.call(
        _slotSelections
            .map((value) => value?.trim() ?? '')
            .toList(growable: false),
      );
      return;
    }
    widget.onSelectionChanged?.call(List<String>.from(_singleSelections));
  }

  void _selectOption(String option) {
    if (widget.showResult) return;
    if (_slotMode) {
      setState(() {
        final next = List<String?>.from(_slotSelections, growable: false);
        final existingIndex = next.indexOf(option);
        if (existingIndex != -1) {
          next[existingIndex] = null;
        } else {
          final firstEmptyIndex = next.indexWhere((value) => value == null);
          if (firstEmptyIndex != -1) {
            next[firstEmptyIndex] = option;
          }
        }
        _slotSelections = next;
      });
      _emitSelectionChanged();
      return;
    }

    setState(() {
      if (_unorderedMultiSelect) {
        if (_singleSelections.contains(option)) {
          _singleSelections.remove(option);
        } else {
          _singleSelections.add(option);
        }
      } else {
        if (_singleSelections.length == 1 && _singleSelections.first == option) {
          _singleSelections = <String>[];
        } else {
          _singleSelections = <String>[option];
        }
      }
    });
    _emitSelectionChanged();
  }

  String? _normalize(String? value) {
    return value?.trim().toLowerCase();
  }

  bool _isCorrectSelection() {
    final expected = _normalizedCorrectAnswers;
    if (expected.isEmpty) return false;

    if (_slotMode) {
      if (_slotSelections.any((value) => value == null || value!.trim().isEmpty)) {
        return false;
      }
      final selected = _slotSelections
          .map((value) => value!.trim().toLowerCase())
          .toList(growable: false);
      if (selected.length != expected.length) return false;
      if (_compactMultiBlank) {
        final selectedSorted = List<String>.from(selected)..sort();
        final expectedSorted = List<String>.from(expected)..sort();
        for (var i = 0; i < selectedSorted.length; i++) {
          if (selectedSorted[i] != expectedSorted[i]) return false;
        }
        return true;
      }
      for (var i = 0; i < selected.length; i++) {
        if (selected[i] != expected[i]) return false;
      }
      return true;
    }

    final selected = _singleSelections
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (_unorderedMultiSelect) {
      if (selected.length != expected.length) return false;
      final selectedSorted = List<String>.from(selected)..sort();
      final expectedSorted = List<String>.from(expected)..sort();
      for (var i = 0; i < selectedSorted.length; i++) {
        if (selectedSorted[i] != expectedSorted[i]) return false;
      }
      return true;
    }
    if (selected.isEmpty) return false;
    return selected.first == expected.first;
  }

  String _selectedValueForDisplay() {
    if (_slotMode) return '';
    if (_singleSelections.isEmpty) return '_____';
    return _singleSelections.join(', ');
  }

  String _renderStem() {
    if (_slotMode) {
      var index = 0;
      return widget.stem.replaceAllMapped(_placeholder, (_) {
        final current = index < _slotSelections.length ? _slotSelections[index] : null;
        index += 1;
        return (current == null || current.trim().isEmpty) ? '_____' : current;
      });
    }

    final replacement = _selectedValueForDisplay();
    if (_placeholder.hasMatch(widget.stem)) {
      return widget.stem.replaceFirst(_placeholder, replacement);
    }
    return '${widget.stem} $replacement';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedCorrect = _normalizedCorrectAnswers;
    final isCorrect = widget.showResult && _isCorrectSelection();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _renderStem(),
            style: AppTextStyles.titleLargeBold(theme),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _shuffledOptions.map((option) {
              final bool isSelected = _slotMode
                  ? _slotSelections.contains(option)
                  : _singleSelections.contains(option);
              final normalizedOption = _normalize(option);
              final bool showCorrect = widget.showResult &&
                  normalizedOption != null &&
                  normalizedCorrect.contains(normalizedOption);
              final bool showWrongSelection =
                  widget.showResult &&
                  isSelected &&
                  normalizedOption != null &&
                  !normalizedCorrect.contains(normalizedOption);

              Color borderColor = theme.dividerColor.withValues(alpha: 0.4);
              Color? fillColor;
              if (showCorrect) {
                borderColor = AppColors.secondary;
                fillColor = AppColors.secondary.withValues(alpha: 0.16);
              } else if (showWrongSelection) {
                borderColor = theme.colorScheme.error;
                fillColor = theme.colorScheme.error.withValues(alpha: 0.16);
              }

              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: widget.showResult ? null : (_) => _selectOption(option),
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.16),
                backgroundColor: fillColor ?? theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor),
                ),
                labelStyle: AppTextStyles.bodyMedium(
                  theme,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          if (widget.showResult &&
              widget.explanationCorrect != null &&
              widget.explanationIncorrect != null &&
              (_slotMode
                  ? _slotSelections.any((value) => value != null)
                  : _singleSelections.isNotEmpty)) ...[
            const SizedBox(height: 12),
            _ResultMessage(
              isCorrect: isCorrect,
              explanationCorrect: widget.explanationCorrect!,
              explanationIncorrect: widget.explanationIncorrect!,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultMessage extends StatelessWidget {
  const _ResultMessage({
    required this.isCorrect,
    required this.explanationCorrect,
    required this.explanationIncorrect,
  });

  final bool isCorrect;
  final String explanationCorrect;
  final String explanationIncorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = isCorrect ? explanationCorrect : explanationIncorrect;
    final color = isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodyMedium(theme, color: color),
          ),
        ),
      ],
    );
  }
}
