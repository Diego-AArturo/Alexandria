import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:flutter/material.dart';

class FillBlankCard extends StatefulWidget {
  const FillBlankCard({
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

  /// Texto con espacio en blanco representado con "___".
  final String stem;

  /// Opciones para rellenar el espacio en blanco.
  final List<String> options;

  /// Seleccion inicial (si el estado se controla externamente).
  final String? initialSelection;

  /// Respuesta correcta para feedback.
  final String? correctAnswer;

  /// Mensaje para respuesta correcta.
  final String? explanationCorrect;

  /// Mensaje para respuesta incorrecta.
  final String? explanationIncorrect;

  /// Callback cuando el usuario selecciona una opcion.
  final ValueChanged<String>? onOptionSelected;

  /// Si es true, muestra feedback y resalta correcto/incorrecto.
  final bool showResult;

  @override
  State<FillBlankCard> createState() => _FillBlankCardState();
}

class _FillBlankCardState extends State<FillBlankCard> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  void didUpdateWidget(covariant FillBlankCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelection != widget.initialSelection) {
      _selected = widget.initialSelection;
    }
  }

  void _handleSelect(String option) {
    if (_selected == option) return;
    setState(() => _selected = option);
    widget.onOptionSelected?.call(option);
  }

  String _renderStem() {
    const fallbackPlaceholder = '_____';
    final placeholder = RegExp(r'_{3,}');
    final replacement = _selected ?? fallbackPlaceholder;

    if (placeholder.hasMatch(widget.stem)) {
      return widget.stem.replaceFirst(placeholder, replacement);
    }
    return '${widget.stem} $replacement';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect =
        widget.showResult && _selected != null && _selected == widget.correctAnswer;

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
            children: widget.options.map((option) {
              final bool isSelected = _selected == option;
              final bool showCorrect = widget.showResult &&
                  widget.correctAnswer == option;
              final bool showWrongSelection =
                  widget.showResult &&
                  isSelected &&
                  widget.correctAnswer != null &&
                  widget.correctAnswer != option;

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
                onSelected: (_) => _handleSelect(option),
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
