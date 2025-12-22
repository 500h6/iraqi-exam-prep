import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SubscriptionPage extends StatelessWidget {
  final String subject;

  const SubscriptionPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الاشتراك المميز'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lock Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'محتوى حصري',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'هذا الاختبار متاح للمشتركين المميزين فقط.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Benefits Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مزايا الاشتراك المميز',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildBenefit(
                      Icons.all_inclusive,
                      'محاولات غير محدودة للاختبارات',
                    ),
                    _buildBenefit(
                      Icons.refresh,
                      'أسئلة محدثة باستمرار',
                    ),
                    _buildBenefit(
                      Icons.support_agent,
                      'دعم فني على مدار الساعة',
                    ),
                    _buildBenefit(
                      Icons.analytics,
                      'تحليلات مفصلة للأداء',
                    ),
                    _buildBenefit(
                      Icons.school,
                      'الوصول إلى جميع المواد',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // How to Subscribe Card
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
                          'طريقة الاشتراك',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. تواصل معنا عبر تيليغرام\n'
                      '2. سنشاركك تفاصيل الأسعار وطرق الدفع المتاحة\n'
                      '3. بعد إتمام الدفع ستحصل على رمز التفعيل\n'
                      '4. أدخل الرمز في صفحة التفعيل للاستفادة من الاشتراك',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Contact Telegram Button
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _launchTelegram(),
                icon: const Icon(Icons.telegram),
                label: const Text('التواصل عبر تيليغرام'),
              ),
            ),
            const SizedBox(height: 12),
            // Have Code Button
            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => context.push('/activation'),
                child: const Text('أملك رمز تفعيل'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
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
