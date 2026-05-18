import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MulChoiceCard extends StatefulWidget {
  const MulChoiceCard({
    super.key,
    required this.stem,
    required this.options,
    this.initialSelection,
    this.correctAnswer,
    this.explanationCorrect,
    this.explanationIncorrect,
    this.onOptionSelected,
    this.showResult = false,
  });

  final String stem;
  final List<String> options;
  final String? initialSelection;
  final String? correctAnswer;
  final String? explanationCorrect;
  final String? explanationIncorrect;
  final ValueChanged<String>? onOptionSelected;
  final bool showResult;

  @override
  State<MulChoiceCard> createState() => _MulChoiceCardState();
}

class _MulChoiceCardState extends State<MulChoiceCard> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  void didUpdateWidget(covariant MulChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelection != widget.initialSelection) {
      _selected = widget.initialSelection;
    }
  }

  void _handleSelect(String option) {
    if (widget.showResult) return;
    if (_selected == option) return;
    setState(() => _selected = option);
    widget.onOptionSelected?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pill(label: l10n.courseScreenSelectOne),
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
        const SizedBox(height: 18),
        ...widget.options.map((option) => _OptionTile(
              option: option,
              isSelected: _selected == option,
              isCorrect: widget.showResult && widget.correctAnswer == option,
              isWrong: widget.showResult &&
                  _selected == option &&
                  widget.correctAnswer != null &&
                  widget.correctAnswer != option,
              showResult: widget.showResult,
              onTap: () => _handleSelect(option),
            )),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.showResult,
    required this.onTap,
  });

  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;
  final VoidCallback onTap;

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
    } else if (isSelected) {
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

    final Color circleBorder =
        isSelected || isCorrect ? textColor : const Color(0xFFDCD5EC);
    final Color circleBg = isCorrect
        ? const Color(0xFF5F2FE2)
        : isWrong
            ? const Color(0xFFFF5A4E)
            : Colors.transparent;

    Widget circleInner;
    if (isCorrect) {
      circleInner =
          const Icon(Icons.check_rounded, color: Colors.white, size: 14);
    } else if (isWrong) {
      circleInner =
          const Icon(Icons.close_rounded, color: Colors.white, size: 14);
    } else if (isSelected) {
      circleInner = Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFF5B2BE3),
          shape: BoxShape.circle,
        ),
      );
    } else {
      circleInner = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: showResult ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: circleBorder, width: 2.5),
                  color: circleBg,
                ),
                alignment: Alignment.center,
                child: circleInner,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
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
