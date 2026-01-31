import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/question_entity.dart';

class ExamResultPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String subject;
  final List<QuestionEntity> questions;
  final Map<String, int> userAnswers;

  const ExamResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.subject,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage>
    with TickerProviderStateMixin {
  late final AnimationController _scoreController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  late final Animation<double> _scoreAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  int get _percentage => (widget.score / widget.totalQuestions * 100).toInt();
  bool get _passed => _percentage >= AppConstants.passingScore;

  Color get _resultColor => _passed ? AppColors.success : AppColors.error;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );

    _scoreAnim = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 140), () => _scaleController.forward());
    Future.delayed(const Duration(milliseconds: 340), () => _scoreController.forward());
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final textPrimary = _isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاختبار'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),

                  // Header (icon + message)
                  _buildHeader(
                    context,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),

                  const SizedBox(height: 16),

                  // Score section
                  _ModernSection(
                    title: 'درجتك',
                    icon: Icons.score_rounded,
                    color: _resultColor,
                    child: _buildScoreCard(
                      context,
                      textSecondary: textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Stats
                  _ModernSection(
                    title: 'الإحصائيات',
                    icon: Icons.analytics_rounded,
                    color: cs.primary,
                    child: _buildStatsRow(context),
                  ),

                  const SizedBox(height: 14),

                  // Subject badge
                  _ModernSection(
                    title: 'المادة',
                    icon: Icons.school_rounded,
                    color: cs.primary,
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildSubjectBadge(context),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Actions
                  _ModernSection(
                    title: 'الخيارات',
                    icon: Icons.grid_view_rounded,
                    color: cs.primary,
                    child: _buildActions(context, textSecondary: textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- Header --------------------

  Widget _buildHeader(
    BuildContext context, {
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _resultColor.withOpacity(_isDark ? 0.20 : 0.14),
                  _resultColor.withOpacity(_isDark ? 0.08 : 0.05),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _resultColor.withOpacity(_isDark ? 0.22 : 0.18),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _resultColor.withOpacity(_isDark ? 0.34 : 0.30),
                      width: 2,
                    ),
                  ),
                ),
                Icon(
                  _passed ? Icons.emoji_events_rounded : Icons.trending_up_rounded,
                  size: 56,
                  color: _resultColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _passed ? 'مبروك! 🎉' : 'حاول مجدداً 💪',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          _passed
              ? 'اجتزت الاختبار بنجاح، استمر في التألق!'
              : 'لم تجتز هذه المرة، لكن كل محاولة تقربك من النجاح!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------- Score Card --------------------

  Widget _buildScoreCard(
    BuildContext context, {
    required Color textSecondary,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedBuilder(
          animation: _scoreAnim,
          builder: (context, _) {
            final animatedPercentage = (_percentage * _scoreAnim.value).toInt();
            final progressValue = (_percentage / 100) * _scoreAnim.value;

            return SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        _isDark
                            ? AppColors.progressBackgroundDark
                            : AppColors.progressBackground,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Transform.rotate(
                      angle: -math.pi / 2,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(_resultColor),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$animatedPercentage%',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _resultColor,
                          fontSize: 48,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _resultColor.withOpacity(_isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _resultColor.withOpacity(_isDark ? 0.30 : 0.22),
                          ),
                        ),
                        child: Text(
                          _passed ? 'ناجح' : 'يحتاج تحسين',
                          style: TextStyle(
                            color: _resultColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'درجة النجاح: ${AppConstants.passingScore}%',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // -------------------- Stats --------------------

  Widget _buildStatsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_rounded,
            label: 'صحيحة',
            value: '${widget.score}',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.cancel_rounded,
            label: 'خاطئة',
            value: '${widget.totalQuestions - widget.score}',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.quiz_rounded,
            label: 'الأسئلة',
            value: '${widget.totalQuestions}',
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  // -------------------- Subject Badge --------------------

  Widget _buildSubjectBadge(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(_isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(_isDark ? 0.30 : 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_rounded, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            _subjectLabel(widget.subject),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Actions --------------------

  Widget _buildActions(BuildContext context, {required Color textSecondary}) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionButton(
          icon: Icons.rate_review_rounded,
          label: 'مراجعة الإجابات',
          isPrimary: false,
          color: AppColors.secondary,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/review-answers', extra: {
              'questions': widget.questions,
              'userAnswers': widget.userAnswers,
            });
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          icon: Icons.refresh_rounded,
          label: 'إعادة الاختبار',
          isPrimary: true,
          color: cs.primary,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/exam/${widget.subject}');
          },
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/home');
          },
          icon: Icon(Icons.home_rounded, color: textSecondary),
          label: Text(
            'العودة للرئيسية',
            style: TextStyle(color: textSecondary, fontSize: 16),
          ),
        ),
      ],
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

// ===================== Shared components (same design system) =====================

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

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.65 : 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isPrimary ? color : color.withOpacity(isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(16),
              border: isPrimary ? null : Border.all(color: color, width: 1.5),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withOpacity(isDark ? 0.20 : 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isPrimary ? Colors.white : color, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
