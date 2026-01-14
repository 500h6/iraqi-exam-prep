import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              phone: widget.phone,
              code: _otpController.text.trim(),
            ),
          );
    }
  }

  void _openTelegramBot() async {
    const botUrl = "https://t.me/IQ1exambot"; // Replace with actual bot User
    if (await canLaunchUrlString(botUrl)) {
      await launchUrlString(botUrl, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Could not open Telegram");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if unlinked state to show "Link" button
    final isUnlinked = context.select((AuthBloc bloc) => bloc.state is AuthUnlinked);

    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الرمز')),
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthProfileIncomplete) {
            context.go('/complete-profile');
          } else if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: AppColors.error,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   const SizedBox(height: 20),
                  Text(
                    'أدخل الرمز الذي وصلك عبر تليكرام',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'تم إرسال الرمز إلى الرقم ${widget.phone}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  if (state is AuthUnlinked) ...[
                     const SizedBox(height: 30),
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.blue.shade50,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.blue.shade200),
                       ),
                       child: Column(
                         children: [
                           const Text(
                             'حسابك غير مربوط بالبوت!',
                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                           ),
                           const SizedBox(height: 8),
                           const Text(
                             'اضغط أدناه لفتح البوت، ثم اضغط "Start" وشارك جهة الاتصال ليتم إرسال الرمز لك.',
                             textAlign: TextAlign.center,
                           ),
                           const SizedBox(height: 16),
                           ElevatedButton.icon(
                             onPressed: _openTelegramBot,
                             icon: const Icon(Icons.telegram),
                             label: const Text('فتح البوت في تليكرام'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.blue,
                               foregroundColor: Colors.white,
                             ),
                           ),
                         ],
                       ),
                     ),
                  ],

                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      hintText: '000000',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return 'الرمز يجب أن يتكون من 6 أرقام';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _verifyOtp,
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تحقق وتسجيل الدخول'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
