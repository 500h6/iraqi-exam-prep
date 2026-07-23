import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/question_entity.dart';

enum ReviewFilter { all, correct, wrong, unanswered }

class ReviewAnswersPage extends StatefulWidget {
  final List<QuestionEntity> questions;
  final Map<String, int> userAnswers;

  const ReviewAnswersPage({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<ReviewAnswersPage> createState() => _ReviewAnswersPageState();
}

class _ReviewAnswersPageState extends State<ReviewAnswersPage> {
  ReviewFilter _filter = ReviewFilter.all;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  bool _isCorrect(QuestionEntity q) {
    final user = widget.userAnswers[q.id];
    return user != null && user == q.correctAnswer;
  }

  bool _isWrong(QuestionEntity q) {
    final user = widget.userAnswers[q.id];
    return user != null && user != q.correctAnswer;
  }

  bool _isUnanswered(QuestionEntity q) => widget.userAnswers[q.id] == null;

  List<QuestionEntity> get _filteredQuestions {
    final list = widget.questions;
    switch (_filter) {
      case ReviewFilter.correct:
        return list.where(_isCorrect).toList();
      case ReviewFilter.wrong:
        return list.where(_isWrong).toList();
      case ReviewFilter.unanswered:
        return list.where(_isUnanswered).toList();
      case ReviewFilter.all:
      default:
        return list;
    }
  }

  int get _correctCount => widget.questions.where(_isCorrect).length;
  int get _wrongCount => widget.questions.where(_isWrong).length;
  int get _unansweredCount => widget.questions.where(_isUnanswered).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = _isDark(context);

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final items = _filteredQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة الإجابات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              cs.primary.withOpacity(isDark ? 0.08 : 0.06),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              // Filter section
              _ModernSection(
                title: 'الفلترة',
                icon: Icons.filter_alt_rounded,
                color: cs.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // counters row
                    Row(
                      children: [
                        Expanded(
                          child: _CountChip(
                            label: 'الكل',
                            value: '${widget.questions.length}',
                            color: cs.primary,
                            isSelected: _filter == ReviewFilter.all,
                            onTap: () => _setFilter(ReviewFilter.all),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CountChip(
                            label: 'صحيحة',
                            value: '$_correctCount',
                            color: AppColors.success,
                            isSelected: _filter == ReviewFilter.correct,
                            onTap: () => _setFilter(ReviewFilter.correct),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _CountChip(
                            label: 'خاطئة',
                            value: '$_wrongCount',
                            color: AppColors.error,
                            isSelected: _filter == ReviewFilter.wrong,
                            onTap: () => _setFilter(ReviewFilter.wrong),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CountChip(
                            label: 'غير مُجابة',
                            value: '$_unansweredCount',
                            color: AppColors.warning,
                            isSelected: _filter == ReviewFilter.unanswered,
                            onTap: () => _setFilter(ReviewFilter.unanswered),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // label
                    Row(
                      children: [
                        Text(
                          'العرض الحالي:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(
                          label: _filterLabel(_filter),
                          color: _filterColor(cs),
                        ),
                        const Spacer(),
                        Text(
                          '${items.length} سؤال',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (items.isEmpty)
                _ModernSection(
                  title: 'لا توجد نتائج',
                  icon: Icons.search_off_rounded,
                  color: AppColors.warning,
                  child: Text(
                    'ماكو أسئلة ضمن هذا الفلتر.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: textSecondary,
                    ),
                  ),
                )
              else
                ...List.generate(items.length, (i) {
                  final q = items[i];

                  // رقم السؤال الحقيقي داخل الامتحان
                  final originalIndex = widget.questions.indexOf(q);

                  final userAnswerIndex = widget.userAnswers[q.id];
                  final answered = userAnswerIndex != null;
                  final correct = answered && userAnswerIndex == q.correctAnswer;

                  final headerColor =
                      !answered ? AppColors.warning : (correct ? AppColors.success : AppColors.error);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ModernQuestionCard(
                      index: originalIndex,
                      question: q,
                      userAnswerIndex: userAnswerIndex,
                      isAnswered: answered,
                      isCorrect: correct,
                      headerColor: headerColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onImageTap: (url) => _showImageDialog(context, url),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _setFilter(ReviewFilter f) {
    HapticFeedback.lightImpact();
    setState(() => _filter = f);
  }

  String _filterLabel(ReviewFilter f) {
    switch (f) {
      case ReviewFilter.correct:
        return 'صحيحة';
      case ReviewFilter.wrong:
        return 'خاطئة';
      case ReviewFilter.unanswered:
        return 'غير مُجابة';
      case ReviewFilter.all:
      default:
        return 'الكل';
    }
  }

  Color _filterColor(ColorScheme cs) {
    switch (_filter) {
      case ReviewFilter.correct:
        return AppColors.success;
      case ReviewFilter.wrong:
        return AppColors.error;
      case ReviewFilter.unanswered:
        return AppColors.warning;
      case ReviewFilter.all:
      default:
        return cs.primary;
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== UI blocks ======================

class _ModernSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _ModernSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: color.withOpacity(0.12), height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isSelected
        ? color.withOpacity(isDark ? 0.22 : 0.14)
        : theme.colorScheme.surface.withOpacity(isDark ? 0.65 : 1);

    final border = isSelected
        ? color.withOpacity(isDark ? 0.55 : 0.40)
        : (isDark ? AppColors.borderDark : AppColors.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: isSelected ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(isDark ? 0.32 : 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ====================== Question card (same as previous) ======================

class _ModernQuestionCard extends StatelessWidget {
  final int index; // original index in exam
  final QuestionEntity question;
  final int? userAnswerIndex;
  final bool isAnswered;
  final bool isCorrect;
  final Color headerColor;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<String> onImageTap;

  const _ModernQuestionCard({
    required this.index,
    required this.question,
    required this.userAnswerIndex,
    required this.isAnswered,
    required this.isCorrect,
    required this.headerColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onImageTap,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: headerColor.withOpacity(isDark ? 0.25 : 0.18),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: headerColor.withOpacity(isDark ? 0.18 : 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: headerColor.withOpacity(isDark ? 0.35 : 0.22),
                      ),
                    ),
                    child: Icon(
                      isAnswered
                          ? (isCorrect
                              ? Icons.check_rounded
                              : Icons.close_rounded)
                          : Icons.help_outline_rounded,
                      color: headerColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'السؤال ${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  _StatusPill(
                    label: !isAnswered
                        ? 'غير مُجاب'
                        : (isCorrect ? 'صحيح' : 'خاطئ'),
                    color: !isAnswered
                        ? AppColors.warning
                        : (isCorrect ? AppColors.success : AppColors.error),
                  ),
                ],
              ),
            ),
            Divider(color: headerColor.withOpacity(0.12), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: () => onImageTap(question.imageUrl!),
                        borderRadius: BorderRadius.circular(18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: Image.network(
                              question.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, p) {
                                if (p == null) return child;
                                return Container(
                                  height: 150,
                                  color: theme.colorScheme.surface
                                      .withOpacity(isDark ? 0.6 : 1),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                height: 110,
                                color: theme.colorScheme.surface
                                    .withOpacity(isDark ? 0.6 : 1),
                                child: Center(
                                  child: Text(
                                    'تعذّر تحميل الصورة',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    question.questionText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(question.options.length, (i) {
                    final isSelected = userAnswerIndex == i;
                    final isCorrectOption = question.correctAnswer == i;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OptionReviewTile(
                        index: i,
                        text: question.options[i],
                        isSelected: isSelected,
                        isCorrectOption: isCorrectOption,
                        showCorrectHint: !isCorrect && isCorrectOption,
                      ),
                    );
                  }),
                  if (question.explanation != null &&
                      question.explanation!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _ExplanationCard(explanation: question.explanation!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionReviewTile extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isCorrectOption;
  final bool showCorrectHint;

  const _OptionReviewTile({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isCorrectOption,
    required this.showCorrectHint,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDark(context);

    final optionLabels = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    final label =
        index < optionLabels.length ? optionLabels[index] : '${index + 1}';

    Color border = isDark ? AppColors.borderDark : AppColors.border;
    Color bg = theme.colorScheme.surface.withOpacity(isDark ? 0.65 : 1);
    Color txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    IconData? trailingIcon;
    Color trailingColor = Colors.transparent;

    if (isSelected && isCorrectOption) {
      bg = AppColors.success.withOpacity(isDark ? 0.18 : 0.10);
      border = AppColors.success.withOpacity(isDark ? 0.55 : 0.45);
      txt = AppColors.success;
      trailingIcon = Icons.check_circle_rounded;
      trailingColor = AppColors.success;
    } else if (isSelected && !isCorrectOption) {
      bg = AppColors.error.withOpacity(isDark ? 0.18 : 0.10);
      border = AppColors.error.withOpacity(isDark ? 0.55 : 0.45);
      txt = AppColors.error;
      trailingIcon = Icons.cancel_rounded;
      trailingColor = AppColors.error;
    } else if (showCorrectHint) {
      bg = AppColors.success.withOpacity(isDark ? 0.14 : 0.06);
      border = AppColors.success.withOpacity(isDark ? 0.40 : 0.30);
      txt = AppColors.success;
      trailingIcon = Icons.check_circle_outline_rounded;
      trailingColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
          width: isSelected || showCorrectHint ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: txt.withOpacity(isDark ? 0.16 : 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: txt.withOpacity(isDark ? 0.25 : 0.18)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: txt,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: txt,
                fontWeight: (isSelected || showCorrectHint)
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 10),
            Icon(trailingIcon, color: trailingColor, size: 22),
          ],
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String explanation;

  const _ExplanationCard({required this.explanation});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.primaryLight : AppColors.primary).withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'التوضيح',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
