import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TrueFalseCard extends StatefulWidget {
  const TrueFalseCard({
    super.key,
    required this.stem,
    this.initialSelection,
    this.correctAnswer,
    this.explanationCorrect,
    this.explanationIncorrect,
    this.onAnswerSelected,
    this.showResult = false,
  });

  final String stem;
  final String? initialSelection;
  final String? correctAnswer;
  final String? explanationCorrect;
  final String? explanationIncorrect;
  final ValueChanged<String>? onAnswerSelected;
  final bool showResult;

  @override
  State<TrueFalseCard> createState() => _TrueFalseCardState();
}

class _TrueFalseCardState extends State<TrueFalseCard> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  void didUpdateWidget(covariant TrueFalseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelection != widget.initialSelection) {
      _selected = widget.initialSelection;
    }
  }

  void _select(String value) {
    if (widget.showResult) return;
    if (_selected == value) return;
    setState(() => _selected = value);
    widget.onAnswerSelected?.call(value);
  }

  String? _normalize(String? value) => value?.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedAnswer = _normalize(widget.correctAnswer);


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pill(label: l10n.courseScreenTrueOrFalse),
        const SizedBox(height: 14),
        Text(
          widget.stem,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1235),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _TFButton(
                label: l10n.courseScreenTrue,
                value: 'True',
                selected: _selected == 'True',
                isCorrect: widget.showResult &&
                    normalizedAnswer != null &&
                    _normalize('True') == normalizedAnswer,
                isWrong: widget.showResult &&
                    _selected == 'True' &&
                    normalizedAnswer != null &&
                    _normalize('True') != normalizedAnswer,
                isTrue: true,
                onTap: () => _select('True'),
                disabled: widget.showResult,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TFButton(
                label: l10n.courseScreenFalse,
                value: 'False',
                selected: _selected == 'False',
                isCorrect: widget.showResult &&
                    normalizedAnswer != null &&
                    _normalize('False') == normalizedAnswer,
                isWrong: widget.showResult &&
                    _selected == 'False' &&
                    normalizedAnswer != null &&
                    _normalize('False') != normalizedAnswer,
                isTrue: false,
                onTap: () => _select('False'),
                disabled: widget.showResult,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TFButton extends StatelessWidget {
  const _TFButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.isCorrect,
    required this.isWrong,
    required this.isTrue,
    required this.onTap,
    required this.disabled,
  });

  final String label;
  final String value;
  final bool selected;
  final bool isCorrect;
  final bool isWrong;
  final bool isTrue;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    Color bg, borderColor, shadowColor, textColor;

    if (isCorrect) {
      bg = const Color(0xFFE2D6FF);
      borderColor = const Color(0xFF5F2FE2);
      shadowColor = const Color(0xFFC7B0FF);
      textColor = const Color(0xFF4D14B8);
    } else if (isWrong) {
      bg = const Color(0xFFFFE4E0);
      borderColor = const Color(0xFFFF5A4E);
      shadowColor = const Color(0xFFFFB5AE);
      textColor = const Color(0xFFC72A38);
    } else if (selected) {
      bg = const Color(0xFFF1ECFF);
      borderColor = const Color(0xFF6B38F2);
      shadowColor = const Color(0xFFC7B0FF);
      textColor = const Color(0xFF4A1FC7);
    } else {
      bg = Colors.white;
      borderColor = const Color(0xFFDCD5EC);
      shadowColor = const Color(0xFFECE7F7);
      textColor = const Color(0xFF1A1235);
    }

    final iconBg = isTrue ? const Color(0xFFE2D6FF) : const Color(0xFFFFE4E0);
    final iconColor =
        isTrue ? const Color(0xFF4D14B8) : const Color(0xFFC72A38);

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                isTrue ? Icons.check_rounded : Icons.close_rounded,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
