import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/question_entity.dart';

class ReviewAnswersPage extends StatelessWidget {
  final List<QuestionEntity> questions;
  final Map<String, int> userAnswers;

  const ReviewAnswersPage({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مراجعة الإجابات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswerIndex = userAnswers[question.id];
          final isCorrect = userAnswerIndex == question.correctAnswer;
          // If the user skipped the question (userAnswerIndex is null), it's treated as wrong (or just unanswered)
          // Based on previous code, submit prevents empty answers, but good to be safe.
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isCorrect 
                    ? AppColors.success.withOpacity(0.5) 
                    : AppColors.error.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Header
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrect 
                            ? AppColors.success.withOpacity(0.1) 
                            : AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: isCorrect ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'السؤال ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Question Text
                  Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Options
                  ...List.generate(
                    question.options.length,
                    (optionIndex) {
                      final isSelected = userAnswerIndex == optionIndex;
                      final isCorrectOption = question.correctAnswer == optionIndex;
                      
                      Color backgroundColor = Colors.transparent;
                      Color borderColor = AppColors.border;
                      Color textColor = AppColors.textPrimary;
                      IconData? icon;
                      Color iconColor = Colors.transparent;

                      if (isSelected) {
                        if (isCorrectOption) {
                          // User selected correct answer
                          backgroundColor = AppColors.success.withOpacity(0.1);
                          borderColor = AppColors.success;
                          textColor = AppColors.success;
                          icon = Icons.check_circle;
                          iconColor = AppColors.success;
                        } else {
                          // User selected wrong answer
                          backgroundColor = AppColors.error.withOpacity(0.1);
                          borderColor = AppColors.error;
                          textColor = AppColors.error;
                          icon = Icons.cancel;
                          iconColor = AppColors.error;
                        }
                      } else if (isCorrectOption) {
                        // This is the correct answer but user didn't select it
                        backgroundColor = AppColors.success.withOpacity(0.05);
                        borderColor = AppColors.success.withOpacity(0.5);
                        textColor = AppColors.success;
                        icon = Icons.check_circle_outline;
                        iconColor = AppColors.success;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                             Text(
                              String.fromCharCode(65 + optionIndex), // A, B, C...
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[optionIndex],
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: isSelected || isCorrectOption 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (icon != null) ...[
                              const SizedBox(width: 8),
                              Icon(icon, color: iconColor, size: 20),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Explanation (if exists)
                  if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'توضيح:',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question.explanation!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
