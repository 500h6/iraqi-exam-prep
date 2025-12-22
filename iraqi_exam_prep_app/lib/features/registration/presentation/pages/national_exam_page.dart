import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NationalExamPage extends StatelessWidget {
  const NationalExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('National Exam Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_reg,
                  size: 50,
                  color: AppColors.info,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Register for National Exam',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your registration for the official competency exams',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About the National Exam',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The national competency exams are required for all students '
                      'applying for Master\'s degree programs in Iraq. The exams cover:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildExamItem('Arabic Language', Icons.language),
                    _buildExamItem('English Language', Icons.translate),
                    _buildExamItem('Computer Skills', Icons.computer),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Requirements Card
            Card(
              color: AppColors.warning.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Required Documents',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Bachelor\'s degree certificate\n'
                      '• Official transcript\n'
                      '• National ID card\n'
                      '• Recent photograph\n'
                      '• Registration fee receipt',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Registration Process Card
            Card(
              color: AppColors.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Registration Process',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Contact us via Telegram\n'
                      '2. Provide your information and documents\n'
                      '3. We\'ll guide you through the registration\n'
                      '4. Receive your exam schedule and details',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Contact Button
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _launchTelegram(),
                icon: const Icon(Icons.telegram),
                label: const Text('Contact via Telegram'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  Future<void> _launchTelegram() async {
    final uri = Uri.parse(AppConstants.telegramUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
