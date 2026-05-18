import 'dart:math';

import 'package:alexandria_movil/l10n/app_localizations.dart';
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

  final String stem;
  final List<String> options;
  final List<String>? initialSelections;
  final List<String>? correctAnswers;
  final String? explanationCorrect;
  final String? explanationIncorrect;
  final ValueChanged<List<String>>? onSelectionChanged;
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
    final matches =
        _placeholder.allMatches(widget.stem).toList(growable: false);
    if (matches.length <= 1) return false;
    for (var i = 0; i < matches.length - 1; i++) {
      final gap = matches[i + 1].start - matches[i].end;
      if (gap >= 7) return false;
    }
    return true;
  }

  List<String> get _normalizedCorrectAnswers =>
      (widget.correctAnswers ?? const [])
          .map((v) => v.trim().toLowerCase())
          .where((v) => v.isNotEmpty)
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
    final changedInitial =
        oldWidget.initialSelections != widget.initialSelections;
    final changedStem = oldWidget.stem != widget.stem;
    final changedAnswers = oldWidget.correctAnswers != widget.correctAnswers;
    final changedOptions = oldWidget.options != widget.options;
    if (changedStem || changedOptions) _shuffleOptions();
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
      final list =
          List<String?>.filled(_blankCount, null, growable: false);
      final limit =
          initial.length < list.length ? initial.length : list.length;
      for (var i = 0; i < limit; i++) {
        final value = initial[i].trim();
        if (value.isNotEmpty) list[i] = value;
      }
      _slotSelections = list;
      _singleSelections = <String>[];
      return;
    }
    _slotSelections = const <String?>[];
    final initial = widget.initialSelections ?? const <String>[];
    if (_unorderedMultiSelect) {
      _singleSelections = initial
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toSet()
          .toList(growable: true);
    } else {
      final first = initial
          .map((v) => v.trim())
          .firstWhere((v) => v.isNotEmpty, orElse: () => '');
      _singleSelections = first.isEmpty ? <String>[] : <String>[first];
    }
  }

  void _emitSelectionChanged() {
    if (_slotMode) {
      widget.onSelectionChanged?.call(
        _slotSelections
            .map((v) => v?.trim() ?? '')
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
        final next =
            List<String?>.from(_slotSelections, growable: false);
        final existingIndex = next.indexOf(option);
        if (existingIndex != -1) {
          next[existingIndex] = null;
        } else {
          final firstEmptyIndex = next.indexWhere((v) => v == null);
          if (firstEmptyIndex != -1) next[firstEmptyIndex] = option;
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
        if (_singleSelections.length == 1 &&
            _singleSelections.first == option) {
          _singleSelections = <String>[];
        } else {
          _singleSelections = <String>[option];
        }
      }
    });
    _emitSelectionChanged();
  }

  String? _normalize(String? value) => value?.trim().toLowerCase();

  bool _isCorrectSelection() {
    final expected = _normalizedCorrectAnswers;
    if (expected.isEmpty) return false;
    if (_slotMode) {
      if (_slotSelections.any((v) => v == null || v.trim().isEmpty)) {
        return false;
      }
      final selected = _slotSelections
          .map((v) => v!.trim().toLowerCase())
          .toList(growable: false);
      if (selected.length != expected.length) return false;
      if (_compactMultiBlank) {
        final ss = List<String>.from(selected)..sort();
        final es = List<String>.from(expected)..sort();
        for (var i = 0; i < ss.length; i++) {
          if (ss[i] != es[i]) return false;
        }
        return true;
      }
      for (var i = 0; i < selected.length; i++) {
        if (selected[i] != expected[i]) return false;
      }
      return true;
    }
    final selected = _singleSelections
        .map((v) => v.trim().toLowerCase())
        .where((v) => v.isNotEmpty)
        .toList(growable: false);
    if (_unorderedMultiSelect) {
      if (selected.length != expected.length) return false;
      final ss = List<String>.from(selected)..sort();
      final es = List<String>.from(expected)..sort();
      for (var i = 0; i < ss.length; i++) {
        if (ss[i] != es[i]) return false;
      }
      return true;
    }
    if (selected.isEmpty) return false;
    return selected.first == expected.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final usedCounts = <String, int>{};
    if (_slotMode) {
      for (final v in _slotSelections) {
        if (v != null) usedCounts[v] = (usedCounts[v] ?? 0) + 1;
      }
    } else {
      for (final v in _singleSelections) {
        usedCounts[v] = (usedCounts[v] ?? 0) + 1;
      }
    }
    final chipCounts = <String, int>{};
    for (final chip in _shuffledOptions) {
      chipCounts[chip] = (chipCounts[chip] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pill(label: l10n.courseScreenFillBlanks),
        const SizedBox(height: 14),
        _buildStemWithSlots(),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _shuffledOptions.map((chip) {
            final isUsed =
                (usedCounts[chip] ?? 0) >= (chipCounts[chip] ?? 0);
            return _ChipOption(
              label: chip,
              isUsed: isUsed,
              onTap: (isUsed || widget.showResult)
                  ? null
                  : () => _selectOption(chip),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStemWithSlots() {
    final stemParts = widget.stem.split(_placeholder);

    if (stemParts.length == 1) {
      final val = _singleSelections.isNotEmpty
          ? _singleSelections.join(', ')
          : null;
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            widget.stem,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1235),
              height: 1.5,
            ),
          ),
          const SizedBox(width: 4),
          _BlankSlot(
            value: val,
            showResult: widget.showResult,
            isCorrect: widget.showResult && _isCorrectSelection(),
            isWrong: widget.showResult && !_isCorrectSelection(),
          ),
        ],
      );
    }

    final spans = <InlineSpan>[];
    for (var i = 0; i < stemParts.length; i++) {
      if (stemParts[i].isNotEmpty) {
        spans.add(
          TextSpan(text: stemParts[i]),
        );
      }
      if (i < stemParts.length - 1) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildSlotAt(i),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1235),
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildSlotAt(int index) {
    String? value;
    bool isSlotCorrect = false;
    bool isSlotWrong = false;

    if (_slotMode) {
      value =
          index < _slotSelections.length ? _slotSelections[index] : null;
      if (widget.showResult && value != null && value.isNotEmpty) {
        final norm = _normalize(value)!;
        final expected = _normalizedCorrectAnswers;
        isSlotCorrect = _compactMultiBlank
            ? expected.contains(norm)
            : (index < expected.length && expected[index] == norm);
        isSlotWrong = !isSlotCorrect;
      }
    } else {
      value = _singleSelections.isNotEmpty
          ? _singleSelections.join(', ')
          : null;
      if (widget.showResult && value != null && value.isNotEmpty) {
        isSlotCorrect = _isCorrectSelection();
        isSlotWrong = !isSlotCorrect;
      }
    }

    final isEmpty = value == null || value.isEmpty;

    return _BlankSlot(
      value: isEmpty ? null : value,
      showResult: widget.showResult,
      isCorrect: widget.showResult && !isEmpty && isSlotCorrect,
      isWrong: widget.showResult && !isEmpty && isSlotWrong,
    );
  }
}

// ─── Private widgets ───────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2D6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4A1FC7),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _BlankSlot extends StatelessWidget {
  const _BlankSlot({
    required this.value,
    required this.showResult,
    required this.isCorrect,
    required this.isWrong,
  });

  final String? value;
  final bool showResult;
  final bool isCorrect;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null || value!.isEmpty;

    Color textColor;
    BoxDecoration decoration;

    if (!isEmpty && showResult && isCorrect) {
      decoration = BoxDecoration(
        color: const Color(0xFF5F2FE2),
        borderRadius: BorderRadius.circular(10),
      );
      textColor = Colors.white;
    } else if (!isEmpty && showResult && isWrong) {
      decoration = BoxDecoration(
        color: const Color(0xFFFF5A4E),
        borderRadius: BorderRadius.circular(10),
      );
      textColor = Colors.white;
    } else if (!isEmpty) {
      decoration = BoxDecoration(
        color: const Color(0xFF5B2BE3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF3F1AAD),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      );
      textColor = Colors.white;
    } else {
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDCD5EC),
          width: 2,
        ),
      );
      textColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      constraints: const BoxConstraints(minWidth: 64),
      decoration: decoration,
      child: Text(
        isEmpty ? ' ' : value!,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ChipOption extends StatelessWidget {
  const _ChipOption({
    required this.label,
    required this.isUsed,
    required this.onTap,
  });

  final String label;
  final bool isUsed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUsed ? const Color(0xFFECE7F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUsed
                ? const Color(0xFFECE7F7)
                : const Color(0xFFDCD5EC),
            width: 2,
          ),
          boxShadow: isUsed
              ? null
              : const [
                  BoxShadow(
                    color: Color(0xFFDCD5EC),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isUsed
                ? const Color(0xFFB5ACC9)
                : const Color(0xFF1A1235),
          ),
        ),
      ),
    );
  }
}
