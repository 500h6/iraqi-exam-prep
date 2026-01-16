import 'package:flutter/material.dart';
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

class _ExamPageState extends State<ExamPage> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};
  List<QuestionEntity> _questions = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExamBloc>()
        ..add(LoadExamQuestionsEvent(widget.subject)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('اختبار ${_subjectLabel(widget.subject)}'),
          actions: [
            BlocBuilder<ExamBloc, ExamState>(
              builder: (context, state) {
                if (state is ExamQuestionsLoaded) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '${_answers.length}/${state.questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ExamQuestionsLoaded) {
              _questions = state.questions;
              final question = state.questions[_currentQuestionIndex];

              return Column(
                children: [
                  // Segmented Progress Bar
                  _buildSegmentedProgress(context, state.questions.length),
                  
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey<int>(_currentQuestionIndex),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Subject & Numbering Chip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _subjectLabel(widget.subject),
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  'السؤال ${_currentQuestionIndex + 1} من ${state.questions.length}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Premium Question Card
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                                      _buildQuestionImage(question.imageUrl!),
                                    Text(
                                      question.questionText,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        height: 1.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Options
                            ...List.generate(
                              question.options.length,
                              (index) => _buildOptionCard(
                                context,
                                question,
                                index,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Premium Floating Navigation Capsule
                  _buildFloatingNavigation(context, state, question),
                ],
              );
            }

            if (state is ExamError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'حدث خطأ',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyLarge,
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
                        child: const Text('العودة للرئيسية'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('تعذّر تحميل الأسئلة'));
          },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _answers[question.id] = optionIndex;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primary.withOpacity(0.08))
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? Colors.white.withOpacity(0.1) : AppColors.border.withOpacity(0.5)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white12 : AppColors.surfaceLight),
                  border: isSelected ? null : Border.all(color: isDark ? Colors.white10 : AppColors.border.withOpacity(0.3)),
                ),
                child: Center(
                  child: isSelected 
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                    : Text(
                        String.fromCharCode(65 + optionIndex),
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question.options[optionIndex],
                  style: TextStyle(
                    color: isSelected 
                        ? (isDark ? Colors.white : AppColors.primary) 
                        : (isDark ? Colors.white70 : AppColors.textPrimary),
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedProgress(BuildContext context, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(total, (index) {
          final bool isCompleted = index < _currentQuestionIndex;
          final bool isCurrent = index == _currentQuestionIndex;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.primary 
                    : isCurrent 
                        ? AppColors.primary.withOpacity(0.3)
                        : Theme.of(context).disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFloatingNavigation(BuildContext context, ExamQuestionsLoaded state, QuestionEntity question) {
    final bool hasPrev = _currentQuestionIndex > 0;
    final bool canNext = _answers.containsKey(question.id);
    final bool isLast = _currentQuestionIndex == state.questions.length - 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              if (hasPrev)
                _buildNavButton(
                  context,
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'السابق',
                  onPressed: () => setState(() => _currentQuestionIndex--),
                  color: Theme.of(context).hintColor,
                  isPrimary: false,
                ),
              if (hasPrev) const SizedBox(width: 10),
              Expanded(
                child: _buildNavButton(
                  context,
                  icon: isLast ? Icons.done_all_rounded : Icons.arrow_forward_ios_rounded,
                  label: isLast ? 'إنهاء الاختبار' : 'التالي',
                  onPressed: canNext 
                      ? () => isLast ? _submitExam(context) : setState(() => _currentQuestionIndex++)
                      : null,
                  color: AppColors.primary,
                  isPrimary: true,
                  iconLeft: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isPrimary = true,
    bool iconLeft = true,
  }) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconLeft) Icon(icon, size: 18),
        if (iconLeft) const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (!iconLeft) const SizedBox(width: 8),
        if (!iconLeft) Icon(icon, size: 18),
      ],
    );

    if (!isPrimary) {
      return IconButton(
        onPressed: onPressed,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        height: 54,
      ),
      child: content,
    );
  }

  Widget _buildQuestionImage(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(
                  child: Image.network(url),
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Image.network(
                url,
                fit: BoxFit.contain,
                height: 220,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    color: AppColors.surfaceLight.withOpacity(0.5),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
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
        title: const Text('تأكيد إرسال الاختبار'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إرسال الإجابات؟ لن تتمكن من تعديلها بعد الإرسال.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
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
