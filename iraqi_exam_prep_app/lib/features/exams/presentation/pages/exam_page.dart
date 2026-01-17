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
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _animateToNextQuestion({bool reverse = false}) {
    _fadeController.reset();
    _slideController.reset();
    
    if (reverse) {
      _slideAnimation = Tween<Offset>(
        begin: const Offset(-0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ));
    } else {
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ));
    }
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExamBloc>()
        ..add(LoadExamQuestionsEvent(widget.subject)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
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
            if (state is ExamLoading) {
              return _buildLoadingState();
            }

            if (state is ExamQuestionsLoaded) {
              _questions = state.questions;
              return _buildExamContent(context, state);
            }

            if (state is ExamError) {
              return _buildErrorState(context, state);
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: _isDarkMode 
          ? SystemUiOverlayStyle.light 
          : SystemUiOverlayStyle.dark,
      title: Text(
        'اختبار ${_subjectLabel(widget.subject)}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state is ExamQuestionsLoaded) {
              return Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isDarkMode 
                      ? AppColors.surfaceDark 
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: _isDarkMode 
                          ? AppColors.primaryLight 
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_answers.length}/${state.questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _isDarkMode 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                _isDarkMode ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل الأسئلة...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
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
        // Progress Section
        _buildProgressSection(state),
        
        // Main Content
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question Card
                    _buildQuestionCard(question),
                    const SizedBox(height: 24),
                    
                    // Options
                    ...List.generate(
                      question.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOptionCard(
                          context,
                          question,
                          index,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Navigation
        _buildNavigationSection(context, state, question),
      ],
    );
  }

  Widget _buildProgressSection(ExamQuestionsLoaded state) {
    final progress = (_currentQuestionIndex + 1) / state.questions.length;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          // Question Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال ${_currentQuestionIndex + 1} من ${state.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _isDarkMode 
                      ? AppColors.primaryLight 
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: _isDarkMode 
                      ? AppColors.progressBackgroundDark 
                      : AppColors.progressBackground,
                  valueColor: AlwaysStoppedAnimation(
                    _isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionEntity question) {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode 
                ? Colors.black.withValues(alpha: 0.3) 
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Image (if any)
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
              GestureDetector(
                onTap: () => _showImageDialog(question.imageUrl!),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: Image.network(
                    question.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: _isDarkMode 
                            ? AppColors.backgroundDark 
                            : AppColors.surfaceLight,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              _isDarkMode 
                                  ? AppColors.primaryLight 
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: _isDarkMode 
                            ? AppColors.backgroundDark 
                            : AppColors.surfaceLight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: _isDarkMode 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تعذّر تحميل الصورة',
                              style: TextStyle(
                                color: _isDarkMode 
                                    ? AppColors.textSecondaryDark 
                                    : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            // Question Text
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                question.questionText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: _isDarkMode 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    QuestionEntity question,
    int optionIndex,
  ) {
    final isSelected = _answers[question.id] == optionIndex;
    final optionLabels = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    final label = optionIndex < optionLabels.length 
        ? optionLabels[optionIndex] 
        : String.fromCharCode(65 + optionIndex);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _answers[question.id] = optionIndex;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (_isDarkMode 
                  ? AppColors.optionSelectedBackgroundDark 
                  : AppColors.optionSelectedBackground)
              : (_isDarkMode 
                  ? AppColors.optionBackgroundDark 
                  : AppColors.optionBackground),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (_isDarkMode 
                    ? AppColors.optionSelectedBorderDark 
                    : AppColors.optionSelectedBorder)
                : (_isDarkMode 
                    ? AppColors.optionBorderDark 
                    : AppColors.optionBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (_isDarkMode 
                        ? AppColors.primaryLight 
                        : AppColors.primary)
                        .withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Option Label Badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (_isDarkMode 
                        ? AppColors.primaryLight 
                        : AppColors.primary)
                    : (_isDarkMode 
                        ? AppColors.backgroundDark 
                        : AppColors.surfaceLight),
                border: isSelected
                    ? null
                    : Border.all(
                        color: _isDarkMode 
                            ? AppColors.borderDark 
                            : AppColors.border,
                        width: 1,
                      ),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (_isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondary),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  child: Text(label),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Option Text
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected
                      ? (_isDarkMode 
                          ? AppColors.primaryLight 
                          : AppColors.primary)
                      : (_isDarkMode 
                          ? AppColors.textPrimaryDark 
                          : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                  height: 1.5,
                ),
                child: Text(question.options[optionIndex]),
              ),
            ),
            
            // Checkmark Icon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1 : 0.5,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isDarkMode 
                        ? AppColors.primaryLight 
                        : AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationSection(
    BuildContext context,
    ExamQuestionsLoaded state,
    QuestionEntity question,
  ) {
    final hasAnswer = _answers.containsKey(question.id);
    final isLastQuestion = _currentQuestionIndex >= state.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: _isDarkMode 
                ? Colors.black.withValues(alpha: 0.3) 
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous Button
            if (_currentQuestionIndex > 0)
              Expanded(
                child: _buildNavButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex--;
                    });
                    _animateToNextQuestion(reverse: true);
                  },
                  label: 'السابق',
                  icon: Icons.arrow_forward_ios,
                  isPrimary: false,
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 12),
            
            // Next/Submit Button
            Expanded(
              flex: _currentQuestionIndex > 0 ? 1 : 2,
              child: _buildNavButton(
                onPressed: hasAnswer
                    ? () {
                        if (!isLastQuestion) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                          _animateToNextQuestion();
                        } else {
                          _submitExam(context);
                        }
                      }
                    : null,
                label: isLastQuestion ? 'إنهاء الاختبار' : 'التالي',
                icon: isLastQuestion ? Icons.check_circle : Icons.arrow_back_ios,
                iconAfter: true,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    bool iconAfter = false,
    required bool isPrimary,
  }) {
    final isEnabled = onPressed != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary
                  ? (isEnabled
                      ? (_isDarkMode ? AppColors.primary : AppColors.primary)
                      : (_isDarkMode 
                          ? AppColors.surfaceDark.withValues(alpha: 0.5) 
                          : AppColors.surfaceLight))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isPrimary
                  ? null
                  : Border.all(
                      color: _isDarkMode 
                          ? AppColors.primaryLight 
                          : AppColors.primary,
                      width: 2,
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!iconAfter) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isPrimary
                        ? (isEnabled ? Colors.white : Colors.grey)
                        : (_isDarkMode 
                            ? AppColors.primaryLight 
                            : AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPrimary
                        ? (isEnabled ? Colors.white : Colors.grey)
                        : (_isDarkMode 
                            ? AppColors.primaryLight 
                            : AppColors.primary),
                  ),
                ),
                if (iconAfter) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: isPrimary
                        ? (isEnabled ? Colors.white : Colors.grey)
                        : (_isDarkMode 
                            ? AppColors.primaryLight 
                            : AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ExamError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ExamBloc>().add(
                    LoadExamQuestionsEvent(widget.subject),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                'العودة للرئيسية',
                style: TextStyle(
                  color: _isDarkMode 
                      ? AppColors.primaryLight 
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: _isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'تعذّر تحميل الأسئلة',
            style: TextStyle(
              fontSize: 18,
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
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

  void _submitExam(BuildContext context) {
    if (_answers.length < _questions.length) {
      Fluttertoast.showToast(
        msg: 'يرجى الإجابة عن جميع الأسئلة قبل إرسال الاختبار',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _isDarkMode ? AppColors.primaryLight : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد الإرسال',
              style: TextStyle(
                color: _isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إرسال الإجابات؟\nلن تتمكن من تعديلها بعد الإرسال.',
          style: TextStyle(
            color: _isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: _isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ExamBloc>().add(
                SubmitExamEvent(
                  subject: widget.subject,
                  answers: _answers,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
