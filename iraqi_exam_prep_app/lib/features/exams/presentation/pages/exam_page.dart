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
                  // Progress Indicator
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) /
                        state.questions.length,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question Number
                          Text(
                            'السؤال ${_currentQuestionIndex + 1} من ${state.questions.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          // Question Text
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: InteractiveViewer(
                                                  child: Image.network(question.imageUrl!),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Image.network(
                                            question.imageUrl!,
                                            fit: BoxFit.contain,
                                            height: 200,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return const SizedBox(
                                                height: 100,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.broken_image, color: Colors.grey),
                                                      Text('حدث خطأ في تحميل الصورة', style: TextStyle(color: Colors.grey)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    question.questionText,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                        ],
                      ),
                    ),
                  ),
                  // Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _currentQuestionIndex--;
                                });
                              },
                            child: const Text('السابق'),
                            ),
                          ),
                        if (_currentQuestionIndex > 0)
                          const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _answers.containsKey(question.id)
                                ? () {
                                    if (_currentQuestionIndex <
                                        state.questions.length - 1) {
                                      setState(() {
                                        _currentQuestionIndex++;
                                      });
                                    } else {
                                      _submitExam(context);
                                    }
                                  }
                                : null,
                            child: Text(
                              _currentQuestionIndex <
                                      state.questions.length - 1
                                  ? 'التالي'
                                  : 'إنهاء الاختبار',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

    return InkWell(
      onTap: () {
        setState(() {
          _answers[question.id] = optionIndex;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + optionIndex), // A, B, C, D
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.options[optionIndex],
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
