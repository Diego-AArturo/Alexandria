import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
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

  /// Enunciado de la pregunta.
  final String stem;

  /// Opciones a mostrar.
  final List<String> options;

  /// Seleccion inicial (util si el estado se controla desde fuera).
  final String? initialSelection;

  /// Respuesta correcta para mostrar feedback (opcional).
  final String? correctAnswer;

  /// Mensaje a mostrar si la respuesta es correcta.
  final String? explanationCorrect;

  /// Mensaje a mostrar si la respuesta es incorrecta.
  final String? explanationIncorrect;

  /// Notifica cuando el usuario selecciona una opcion.
  final ValueChanged<String>? onOptionSelected;

  /// Si es true, muestra feedback y resalta correcto/incorrecto.
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
    final theme = Theme.of(context);

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
          ...widget.options.map(
            (option) {
              final bool isSelected = _selected == option;
              final bool isCorrect =
                  widget.showResult && widget.correctAnswer == option;
              final bool isWrongSelection = widget.showResult &&
                  isSelected &&
                  widget.correctAnswer != null &&
                  widget.correctAnswer != option;

              Color tileColor = theme.cardColor;
              if (isCorrect) {
                tileColor = AppColors.secondary.withValues(alpha: 0.14);
              } else if (isWrongSelection) {
                tileColor = theme.colorScheme.error.withValues(alpha: 0.12);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: widget.showResult ? null : () => _handleSelect(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: option,
                            groupValue: _selected,
                            onChanged: widget.showResult ? null : (_) => _handleSelect(option),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option,
                              style: AppTextStyles.bodyLarge(theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.showResult &&
              widget.correctAnswer != null &&
              widget.explanationCorrect != null &&
              widget.explanationIncorrect != null) ...[
            const SizedBox(height: 8),
            _ResultMessage(
              isCorrect: _selected == widget.correctAnswer,
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
