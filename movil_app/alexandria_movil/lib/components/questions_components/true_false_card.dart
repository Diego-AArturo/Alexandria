import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
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
    this.trueLabel = 'True',
    this.falseLabel = 'False',
  });

  /// Enunciado de la pregunta.
  final String stem;

  /// Seleccion inicial (si el estado es controlado externamente).
  final String? initialSelection;

  /// Respuesta correcta para feedback.
  final String? correctAnswer;

  /// Mensaje para respuesta correcta.
  final String? explanationCorrect;

  /// Mensaje para respuesta incorrecta.
  final String? explanationIncorrect;

  /// Callback cuando el usuario selecciona una respuesta.
  final ValueChanged<String>? onAnswerSelected;

  /// Si es true, muestra feedback y resalta correcto/incorrecto.
  final bool showResult;

  /// Etiquetas personalizables.
  final String trueLabel;
  final String falseLabel;

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
    if (_selected == value) return;
    setState(() => _selected = value);
    widget.onAnswerSelected?.call(value);
  }

  String? _normalize(String? value) {
    return value?.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [widget.trueLabel, widget.falseLabel];
    final normalizedAnswer = _normalize(widget.correctAnswer);
    
    
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
            widget.stem,
            style: AppTextStyles.titleLargeBold(theme),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            children: options.map((option) {
              final bool isSelected = _selected == option;
              final bool isCorrect = widget.showResult &&
                  normalizedAnswer != null &&
                  _normalize(option) == normalizedAnswer;
              final bool isWrongSelected = widget.showResult &&
                  isSelected &&
                  normalizedAnswer != null &&
                  _normalize(option) != normalizedAnswer;

              Color borderColor = theme.dividerColor.withValues(alpha: 0.4);
              Color? fillColor;
              if (isCorrect) {
                borderColor = AppColors.secondary;
                fillColor = AppColors.secondary.withValues(alpha: 0.16);
              } else if (isWrongSelected) {
                borderColor = theme.colorScheme.error;
                fillColor = theme.colorScheme.error.withValues(alpha: 0.16);
              }

              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (_) => _select(option),
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
              widget.correctAnswer != null &&
              widget.explanationCorrect != null &&
              widget.explanationIncorrect != null &&
              _selected != null) ...[
            const SizedBox(height: 12),
            _ResultMessage(
              isCorrect: normalizedAnswer != null &&
                  _normalize(_selected) == normalizedAnswer,
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
