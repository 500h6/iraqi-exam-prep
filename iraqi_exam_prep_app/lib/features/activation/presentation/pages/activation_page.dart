import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/activation_bloc.dart';
import '../bloc/activation_event.dart';
import '../bloc/activation_state.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivationBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تفعيل الاشتراك المميز'),
        ),
        body: BlocConsumer<ActivationBloc, ActivationState>(
          listener: (context, state) {
            if (state is ActivationSuccess) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: AppColors.success,
              );
              // Navigate back to home and refresh
              context.go('/home');
            } else if (state is ActivationError) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: AppColors.error,
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.vpn_key,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'أدخل رمز التفعيل',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل رمز التفعيل الذي استلمته عبر تيليغرام',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Code Input
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'رمز التفعيل',
                        prefixIcon: Icon(Icons.code),
                        hintText: 'XXXX-XXXX-XXXX',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رمز التفعيل';
                        }
                        if (value.length < 6) {
                          return 'صيغة رمز غير صحيحة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Activate Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state is ActivationLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<ActivationBloc>().add(
                                        ValidateActivationCodeEvent(
                                          _codeController.text.trim(),
                                        ),
                                      );
                                }
                              },
                        child: state is ActivationLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('تفعيل'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Card
                    Card(
                      color: AppColors.info.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'معلومة',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppColors.info),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'إذا لم تحصل على رمز التفعيل بعد، تواصل معنا عبر تيليغرام لشراء الاشتراك والحصول على الرمز.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
