import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/exams/presentation/pages/home_page.dart';
import '../../features/exams/presentation/pages/exam_page.dart';
import '../../features/exams/presentation/pages/exam_result_page.dart';
import '../../features/activation/presentation/pages/subscription_page.dart';
import '../../features/activation/presentation/pages/activation_page.dart';
import '../../features/registration/presentation/pages/national_exam_page.dart';
import '../../features/admin/presentation/pages/admin_question_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'البدء',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'تسجيل الدخول',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'إنشاء حساب',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'الرئيسية',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/exam/:subject',
        name: 'exam',
        builder: (context, state) {
          final subject = state.pathParameters['subject']!;
          return ExamPage(subject: subject);
        },
      ),
      GoRoute(
        path: '/exam-result',
        name: 'نتيجة الامتحان',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ExamResultPage(
            score: extra['score'] as int,
            totalQuestions: extra['totalQuestions'] as int,
            subject: extra['subject'] as String,
          );
        },
      ),
      GoRoute(
        path: '/subscription',
        name: 'الاشتراك',
        builder: (context, state) {
          final subject = state.extra as String;
          return SubscriptionPage(subject: subject);
        },
      ),
      GoRoute(
        path: '/activation',
        name: 'التفعيل',
        builder: (context, state) => const ActivationPage(),
      ),
      GoRoute(
        path: '/national-exam',
        name: 'الامتحان الوطني',
        builder: (context, state) => const NationalExamPage(),
      ),
      GoRoute(
        path: '/admin/questions',
        name: 'إدارة الأسئلة',
        builder: (context, state) => const AdminQuestionPage(),
      ),
    ],
  );
}
