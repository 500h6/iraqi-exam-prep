import 'package:flutter/material.dart';

class PrivacySection {
  final String title;
  final String content;
  final IconData icon;

  const PrivacySection({
    required this.title,
    required this.content,
    required this.icon,
  });
}

class PrivacyContent {
  static const List<PrivacySection> sections = [
    PrivacySection(
      title: '1. مقدمة',
      content: 'نحن في تطبيق "الامتحان الوطني" نولي أهمية قصوى لخصوصية مستخدمينا. توضح سياسة الخصوصية هذه كيفية جمعنا واستخدامنا وحمايتنا لمعلوماتك الشخصية عند استخدامك لتطبيقنا.',
      icon: Icons.security_rounded,
    ),
    PrivacySection(
      title: '2. المعلومات التي نجمعها',
      content: 'قد نجمع المعلومات التالية لتقديم خدماتنا وتحسينها:\n\n'
          '• المعلومات الشخصية: مثل الاسم، رقم الهاتف عند التسجيل.\n'
          '• بيانات الاستخدام: معلومات حول كيفية استخدامك للتطبيق، مثل الاختبارات التي تم إجراؤها والنتائج.\n'
          '• معلومات الجهاز: نوع الجهاز، نظام التشغيل، والمميزات الفريدة للجهاز.',
      icon: Icons.data_usage_rounded,
    ),
    PrivacySection(
      title: '3. خدمات الطرف الثالث',
      content: 'نستخدم خدمات موثوقة لمساعدتنا في تشغيل التطبيق:\n\n'
          '• Supabase: نستخدم Supabase لتخزين بيانات المستخدمين والمصادقة بشكل آمن.\n'
          '• Google Play Services: لتحسين أداء التطبيق وجمع إحصائيات الاستخدام غير المعرفة.',
      icon: Icons.cloud_sync_rounded,
    ),
    PrivacySection(
      title: '4. استخدام البيانات',
      content: 'نستخدم البيانات التي نجمعها للأغراض التالية:\n\n'
          '• إدارة حسابك وتوفير الخدمات المطلوبة.\n'
          '• تحسين تجربة المستخدم وأداء التطبيق.\n'
          '• التواصل معك بخصوص التحديثات أو الدعم الفني.\n'
          '• الامتثال للمتطلبات القانونية.',
      icon: Icons.analytics_rounded,
    ),
    PrivacySection(
      title: '5. أمان البيانات',
      content: 'نحن نطبق إجراءات أمان صارمة لحماية بياناتك من الوصول غير المصرح به أو التغيير أو الكشف أو الإتلاف. يتم تشفير البيانات الحساسة ونستخدم بروتوكولات اتصال آمنة.',
      icon: Icons.verified_user_rounded,
    ),
    PrivacySection(
      title: '6. حذف الحساب',
      content: 'لديك الحق في طلب حذف حسابك وجميع البيانات المرتبطة به في أي وقت. يمكنك القيام بذلك من خلال إعدادات التطبيق أو التواصل معنا مباشرة.',
      icon: Icons.delete_forever_rounded,
    ),
  ];
}
