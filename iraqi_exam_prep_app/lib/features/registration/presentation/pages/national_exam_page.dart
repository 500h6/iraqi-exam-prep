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
        title: const Text('التسجيل في الامتحان الوطني'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
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
                'التسجيل في الامتحان الوطني',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'أكمل تسجيلك للامتحانات التنافسية الرسمية',
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
                        'عن الامتحان الوطني',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'الامتحان الوطني الموحد هو شرط أساسي للتقديم للدراسات العليا (الماجستير والدكتوراه) في الجامعات العراقية. يشمل الامتحان:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildExamItem('اللغة العربية', Icons.language),
                      _buildExamItem('اللغة الإنجليزية', Icons.translate),
                      _buildExamItem('الحاسوب', Icons.computer),
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
                            'المعلومات المطلوبة للتسجيل',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لإتمام الحجز، يرجى تحضير المعلومات التالية وإرسالها لنا:\n\n'
                        '✅ الاسم الرباعي\n'
                        '✅ اسم الأم الثلاثي\n'
                        '✅ رقم البطاقة الوطنية\n'
                        '✅ رقم الهاتف',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
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
                            'طريقة التسجيل',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. اضغط على زر "التسجيل عبر تليكرام" أدناه.\n'
                        '2. أرسل المعلومات المطلوبة أعلاه.\n'
                        '3. سيقوم فريقنا بإكمال إجراءات الحجز وتزويدك بموعد الامتحان وتفاصيله.\n',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
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
                  label: const Text('التسجيل عبر تليكرام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, 
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
