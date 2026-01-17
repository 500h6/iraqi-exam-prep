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
  late AnimationController _scoreAnimationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  int get _percentage => (widget.score / widget.totalQuestions * 100).toInt();
  bool get _passed => _percentage >= AppConstants.passingScore;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Score counter animation
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Scale pop animation for icon
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations in sequence
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scoreAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Color get _resultColor => _passed ? AppColors.success : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Result Icon with Animation
                _buildResultIcon(),
                const SizedBox(height: 28),
                
                // Title & Message
                _buildResultMessage(),
                const SizedBox(height: 40),
                
                // Score Card
                _buildScoreCard(),
                const SizedBox(height: 24),
                
                // Stats Row
                _buildStatsRow(),
                const SizedBox(height: 32),
                
                // Subject Badge
                _buildSubjectBadge(),
                const SizedBox(height: 40),
                
                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _resultColor.withValues(alpha: 0.15),
              _resultColor.withValues(alpha: 0.05),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _resultColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _resultColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            // Icon
            Icon(
              _passed ? Icons.emoji_events_rounded : Icons.trending_up_rounded,
              size: 56,
              color: _resultColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultMessage() {
    return Column(
      children: [
        Text(
          _passed ? 'مبروك! 🎉' : 'حاول مجدداً 💪',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: _isDarkMode 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _passed
                ? 'اجتزت الاختبار بنجاح، استمر في التألق!'
                : 'لم تجتز هذه المرة، لكن كل محاولة تقربك من النجاح!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode 
                ? Colors.black.withValues(alpha: 0.3) 
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Score Circle
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              final animatedPercentage = (_percentage * _scoreAnimation.value).toInt();
              final progressValue = _percentage / 100 * _scoreAnimation.value;
              
              return SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          _isDarkMode 
                              ? AppColors.progressBackgroundDark 
                              : AppColors.progressBackground,
                        ),
                      ),
                    ),
                    // Progress circle
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
                    // Center content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$animatedPercentage%',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _resultColor,
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _resultColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _passed ? 'ناجح' : 'يحتاج تحسين',
                            style: TextStyle(
                              color: _resultColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
          const SizedBox(height: 8),
          Text(
            'درجة النجاح: ${AppConstants.passingScore}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            label: 'صحيحة',
            value: '${widget.score}',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.cancel_rounded,
            label: 'خاطئة',
            value: '${widget.totalQuestions - widget.score}',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz_rounded,
            label: 'الأسئلة',
            value: '${widget.totalQuestions}',
            color: _isDarkMode ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: (_isDarkMode ? AppColors.primaryLight : AppColors.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: (_isDarkMode ? AppColors.primaryLight : AppColors.primary)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_rounded,
            size: 20,
            color: _isDarkMode ? AppColors.primaryLight : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _subjectLabel(widget.subject),
            style: TextStyle(
              color: _isDarkMode ? AppColors.primaryLight : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Review Answers Button
        _buildActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/review-answers', extra: {
              'questions': widget.questions,
              'userAnswers': widget.userAnswers,
            });
          },
          icon: Icons.rate_review_rounded,
          label: 'مراجعة الإجابات',
          isPrimary: false,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        
        // Retry Button
        _buildActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/exam/${widget.subject}');
          },
          icon: Icons.refresh_rounded,
          label: 'إعادة الاختبار',
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        
        // Home Button
        TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/home');
          },
          icon: Icon(
            Icons.home_rounded,
            color: _isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondary,
          ),
          label: Text(
            'العودة للرئيسية',
            style: TextStyle(
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    Color? color,
  }) {
    final buttonColor = color ?? 
        (_isDarkMode ? AppColors.primaryLight : AppColors.primary);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isPrimary 
                  ? buttonColor 
                  : buttonColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: isPrimary 
                  ? null 
                  : Border.all(color: buttonColor, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : buttonColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : buttonColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
