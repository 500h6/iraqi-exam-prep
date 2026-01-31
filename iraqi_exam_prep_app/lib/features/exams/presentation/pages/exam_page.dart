import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';

import '../../domain/entities/question_entity.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';

class ExamPage extends StatefulWidget {
  final String subject;

  const ExamPage({super.key, required this.subject});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};
  List<QuestionEntity> _questions = [];

  // Animations
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _animateToQuestion({required bool reverse}) {
    _fadeController.reset();
    _slideController.reset();

    _slideAnimation = Tween<Offset>(
      begin: reverse ? const Offset(-0.04, 0) : const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocProvider(
      create: (_) => getIt<ExamBloc>()..add(LoadExamQuestionsEvent(widget.subject)),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocConsumer<ExamBloc, ExamState>(
          listener: (context, state) {
            if (state is ExamSubmitted) {
              context.go('/exam-result', extra: {
                'score': state.result.score,
                'totalQuestions': state.result.totalQuestions,
                'subject': widget.subject,
                'questions': state.result.questions ?? _questions,
                'answers': _answers,
              });
            } else if (state is ExamError) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: AppColors.error,
              );
            }
          },
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    cs.primary.withOpacity(_isDark ? 0.08 : 0.06),
                  ],
                ),
              ),
              child: _buildStateBody(context, state),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      title: Text(
        'اختبار ${_subjectLabel(widget.subject)}',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state is! ExamQuestionsLoaded) return const SizedBox.shrink();

            final answered = _answers.length;
            final total = state.questions.length;

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(_isDark ? 0.72 : 1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: cs.primary.withOpacity(_isDark ? 0.22 : 0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$answered/$total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStateBody(BuildContext context, ExamState state) {
    if (state is ExamLoading) return _buildLoadingState(context);

    if (state is ExamQuestionsLoaded) {
      _questions = state.questions;
      if (_currentQuestionIndex >= _questions.length) {
        _currentQuestionIndex = 0;
      }
      return _buildExamContent(context, state);
    }

    if (state is ExamError) return _buildErrorState(context, state);

    return _buildEmptyState(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'جاري تحميل الأسئلة...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamContent(BuildContext context, ExamQuestionsLoaded state) {
    final question = state.questions[_currentQuestionIndex];

    return Column(
      children: [
        _ProgressHeader(
          currentIndex: _currentQuestionIndex,
          total: state.questions.length,
        ),

        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuestionCard(
                      question: question,
                      onImageTap: (url) => _showImageDialog(url),
                    ),
                    const SizedBox(height: 14),

                    ...List.generate(
                      question.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionTile(
                          labelIndex: index,
                          text: question.options[index],
                          isSelected: _answers[question.id] == index,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _answers[question.id] = index);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ),

        _BottomNavBar(
          canGoBack: _currentQuestionIndex > 0,
          isLast: _currentQuestionIndex >= state.questions.length - 1,
          hasAnswer: _answers.containsKey(question.id),
          onBack: () {
            setState(() => _currentQuestionIndex--);
            _animateToQuestion(reverse: true);
          },
          onNextOrSubmit: () {
            final isLastQuestion = _currentQuestionIndex >= state.questions.length - 1;
            if (!isLastQuestion) {
              setState(() => _currentQuestionIndex++);
              _animateToQuestion(reverse: false);
            } else {
              _submitExam(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, ExamError state) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 42, color: AppColors.error),
            ),
            const SizedBox(height: 18),
            Text(
              'حدث خطأ',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ExamBloc>().add(
                        LoadExamQuestionsEvent(widget.subject),
                      );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                'العودة للرئيسية',
                style: TextStyle(color: cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'تعذّر تحميل الأسئلة',
            style: theme.textTheme.titleMedium?.copyWith(
              color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Dialogs & Submit --------------------

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitExam(BuildContext context) {
    if (_answers.length < _questions.length) {
      Fluttertoast.showToast(
        msg: 'يرجى الإجابة عن جميع الأسئلة قبل إرسال الاختبار',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(_isDark ? 0.18 : 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('تأكيد الإرسال'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إرسال الإجابات؟\nلن تتمكن من تعديلها بعد الإرسال.',
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ExamBloc>().add(
                    SubmitExamEvent(subject: widget.subject, answers: _answers),
                  );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  String _subjectLabel(String subject) {
    switch (subject.toLowerCase()) {
      case 'arabic':
        return 'اللغة العربية';
      case 'english':
        return 'اللغة الإنجليزية';
      case 'computer':
        return 'مهارات الحاسوب';
      default:
        return subject;
    }
  }
}

// ====================== Components ======================

class _ProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int total;

  const _ProgressHeader({
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final progress = (currentIndex + 1) / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'السؤال ${currentIndex + 1} من $total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: isDark
                    ? AppColors.progressBackgroundDark
                    : AppColors.progressBackground,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionEntity question;
  final ValueChanged<String> onImageTap;

  const _QuestionCard({
    required this.question,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: cs.primary.withOpacity(isDark ? 0.16 : 0.10),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
              InkWell(
                onTap: () => onImageTap(question.imageUrl!),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: Image.network(
                    question.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, p) {
                      if (p == null) return child;
                      return Container(
                        height: 150,
                        color: theme.colorScheme.surface.withOpacity(isDark ? 0.6 : 1),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: p.expectedTotalBytes != null
                                ? p.cumulativeBytesLoaded / p.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 110,
                      color: theme.colorScheme.surface.withOpacity(isDark ? 0.6 : 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تعذّر تحميل الصورة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                question.questionText,
                style: theme.textTheme.titleLarge?.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int labelIndex;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.labelIndex,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final optionLabels = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    final label = labelIndex < optionLabels.length
        ? optionLabels[labelIndex]
        : String.fromCharCode(65 + labelIndex);

    final bg = isSelected
        ? cs.primary.withOpacity(isDark ? 0.20 : 0.10)
        : theme.cardColor.withOpacity(isDark ? 0.72 : 1);

    final border = isSelected
        ? cs.primary.withOpacity(isDark ? 0.60 : 0.45)
        : (isDark ? AppColors.borderDark : AppColors.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: isSelected ? 1.6 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(isDark ? 0.18 : 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? cs.primary
                      : theme.colorScheme.surface.withOpacity(isDark ? 0.65 : 1),
                  border: isSelected
                      ? null
                      : Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? cs.primary : null,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isSelected ? 1 : 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final bool canGoBack;
  final bool isLast;
  final bool hasAnswer;
  final VoidCallback onBack;
  final VoidCallback onNextOrSubmit;

  const _BottomNavBar({
    required this.canGoBack,
    required this.isLast,
    required this.hasAnswer,
    required this.onBack,
    required this.onNextOrSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isDark ? 0.92 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              if (canGoBack) ...[
                Expanded(
                  child: _NavButton(
                    label: 'السابق',
                    icon: Icons.arrow_forward_ios_rounded,
                    isPrimary: false,
                    enabled: true,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: canGoBack ? 1 : 2,
                child: _NavButton(
                  label: isLast ? 'إنهاء الاختبار' : 'التالي',
                  icon: isLast ? Icons.check_circle_rounded : Icons.arrow_back_ios_rounded,
                  isPrimary: true,
                  enabled: hasAnswer,
                  onTap: onNextOrSubmit,
                  primaryColor: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool enabled;
  final VoidCallback onTap;
  final Color? primaryColor;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.enabled,
    required this.onTap,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final p = primaryColor ?? cs.primary;

    final bg = isPrimary
        ? (enabled ? p : theme.disabledColor.withOpacity(isDark ? 0.22 : 0.12))
        : Colors.transparent;

    final border = isPrimary ? null : BorderSide(color: p, width: 1.6);

    final fg = isPrimary
        ? (enabled ? Colors.white : (isDark ? Colors.white54 : Colors.black45))
        : p;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.65,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: border == null ? null : Border.fromBorderSide(border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
