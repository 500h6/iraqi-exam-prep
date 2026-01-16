import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NationalExamPage extends StatelessWidget {
  const NationalExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التسجيل في الامتحان الوطني'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeader(context),
              const SizedBox(height: 32),
              
              // Info Sections
              _buildModernSection(
                context,
                title: 'عن الامتحان الوطني',
                icon: Icons.info_rounded,
                color: AppColors.primary,
                content: Column(
                  children: [
                    Text(
                      'الامتحان الوطني الموحد هو شرط أساسي للتقديم للدراسات العليا (الماجستير والدكتوراه) في الجامعات العراقية.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCompactItem(context, 'العربية', Icons.language, AppColors.arabicColor),
                        _buildCompactItem(context, 'الإنجليزية', Icons.translate, AppColors.englishColor),
                        _buildCompactItem(context, 'الحاسوب', Icons.computer, AppColors.computerColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildModernSection(
                context,
                title: 'المتطلبات الأساسية',
                icon: Icons.assignment_turned_in_rounded,
                color: AppColors.warning,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirementRow(context, 'الاسم الرباعي الكامل كما في البطاقة الشخصية'),
                    _buildRequirementRow(context, 'اسم الأم الثلاثي'),
                    _buildRequirementRow(context, 'رقم البطاقة الوطنية الموحدة'),
                    _buildRequirementRow(context, 'رقم هاتف مفعل للإشعارات'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildModernSection(
                context,
                title: 'آلية الحجز والتسجيل',
                icon: Icons.ads_click_rounded,
                color: AppColors.success,
                content: Text(
                  'عملية التسجيل تتم بكل سهولة؛ ما عليك سوى الضغط على الزر أدناه لإرسال بياناتك عبر تليكرام، وسيقوم فريقنا المختص بإتمام كافة إجراءات الحجز وتزويدك بالوصل الرسمي وموعد الامتحان.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
                ),
              ),
              const SizedBox(height: 40),

              // Premium CTA Button
              _buildTelegramButton(context),
              const SizedBox(height: 20),
              
              Text(
                'ملاحظة: سيتم الرد على طلباتكم خلال ساعات الدوام الرسمي',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'بوابتك للدراسات العليا',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          Divider(color: color.withOpacity(0.1), height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactItem(BuildContext context, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelegramButton(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0088CC).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF0088CC), Color(0xFF24A1DE)],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchTelegram(),
        icon: const Icon(Icons.telegram, size: 28),
        label: const Text(
          'التسجيل الفوري عبر تليكرام',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
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
