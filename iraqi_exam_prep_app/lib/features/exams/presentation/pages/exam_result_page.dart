import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ExamResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String subject;

  const ExamResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).toInt();
    final passed = percentage >= AppConstants.passingScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Result Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: passed
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 80,
                  color: passed ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                passed ? 'أحسنت!' : 'تابع التدريب!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'اجتزت الاختبار بنجاح، استمر في التألق!'
                    : 'لم تجتز الاختبار هذه المرة، لكن الفرصة ما زالت أمامك!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Score Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Percentage Circle
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 12,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation(
                                passed ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$percentage%',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: passed
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                              ),
                              Text(
                                'نسبة النجاح',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            context,
                            'إجابات صحيحة',
                            '$score',
                            AppColors.success,
                          ),
                          _buildStat(
                            context,
                            'إجابات خاطئة',
                            '${totalQuestions - score}',
                            AppColors.error,
                          ),
                          _buildStat(
                            context,
                            'عدد الأسئلة',
                            '$totalQuestions',
                            AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Subject Info
              Text(
                'المادة: ${_subjectLabel(subject)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!passed) ...[
                const SizedBox(height: 8),
                Text(
                  'النجاح من ${AppConstants.passingScore}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 40),
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('العودة للرئيسية'),
                ),
              ),
              if (!passed) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      context.pop();
                      context.push('/exam/$subject');
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
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
