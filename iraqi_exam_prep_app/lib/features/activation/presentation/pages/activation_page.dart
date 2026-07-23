import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';

import '../bloc/activation_bloc.dart';
import '../bloc/activation_event.dart';
import '../bloc/activation_state.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import '../widgets/activation_success_dialog.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _submittedOnce = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _submittedOnce = true);

    final form = _formKey.currentState;
    if (form == null) return;

    if (form.validate()) {
      FocusScope.of(context).unfocus();
      context.read<ActivationBloc>().add(
            ValidateActivationCodeEvent(_codeController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return BlocProvider(
      create: (_) => getIt<ActivationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفعيل الاشتراك المميز'),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocConsumer<ActivationBloc, ActivationState>(
            listener: (context, state) async {
              if (state is ActivationSuccess) {
                // 1) Sync user state
                final authBloc = context.read<AuthBloc>();
                if (state.user != null) {
                  authBloc.add(UpdateUserEvent(state.user!));
                } else {
                  authBloc.add(CheckAuthStatusEvent());
                }

                // 2) Success dialog
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const ActivationSuccessDialog(),
                );

                // 3) Navigate
                if (context.mounted) context.go('/home');
              } else if (state is ActivationError) {
                Fluttertoast.showToast(
                  msg: state.message,
                  backgroundColor: AppColors.error,
                );
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor,
                          cs.primary.withOpacity(isDark ? 0.08 : 0.06),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 24,
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: _submittedOnce
                                    ? AutovalidateMode.onUserInteraction
                                    : AutovalidateMode.disabled,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeader(
                                      context,
                                      cs: cs,
                                      isDark: isDark,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    ),
                                    const SizedBox(height: 18),

                                    _buildModernCard(
                                      context,
                                      title: 'أدخل رمز التفعيل',
                                      icon: Icons.vpn_key_rounded,
                                      color: cs.primary,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'أدخل رمز التفعيل الذي استلمته عبر تيليغرام',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              height: 1.6,
                                              color: textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 18),

                                          TextFormField(
                                            controller: _codeController,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (_) =>
                                                state is ActivationLoading
                                                    ? null
                                                    : _submit(context),
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[A-Za-z0-9\-]')),
                                              LengthLimitingTextInputFormatter(
                                                  32),
                                            ],
                                            decoration: InputDecoration(
                                              labelText: 'رمز التفعيل',
                                              hintText: 'XXXX-XXXX-XXXX',
                                              prefixIcon: const Icon(
                                                  Icons.code_rounded),
                                              filled: true,
                                              fillColor: cs.surface
                                                  .withOpacity(isDark ? 0.60 : 1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderDark
                                                      : AppColors.border,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderDark
                                                          .withOpacity(0.8)
                                                      : AppColors.border,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: cs.primary,
                                                  width: 1.4,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              final v = value?.trim() ?? '';
                                              if (v.isEmpty) {
                                                return 'يرجى إدخال رمز التفعيل';
                                              }
                                              if (v.length < 6) {
                                                return 'صيغة رمز غير صحيحة';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(height: 18),

                                          // CTA
                                          ScaleTransition(
                                            scale: state is ActivationLoading
                                                ? const AlwaysStoppedAnimation(
                                                    1.0)
                                                : _pulseAnimation,
                                            child: _buildPrimaryButton(
                                              context,
                                              isLoading:
                                                  state is ActivationLoading,
                                              onPressed: () => _submit(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    _buildModernCard(
                                      context,
                                      title: 'معلومة',
                                      icon: Icons.info_outline_rounded,
                                      color: AppColors.info,
                                      child: Text(
                                        'إذا لم تحصل على رمز التفعيل بعد، تواصل معنا عبر تيليغرام لشراء الاشتراك والحصول على الرمز.',
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          height: 1.7,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      'سيتم الرد على طلباتكم بأقرب وقت',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.hintColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // -------------------- UI pieces --------------------

  Widget _buildHeader(
    BuildContext context, {
    required ColorScheme cs,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(isDark ? 0.16 : 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: cs.primary.withOpacity(isDark ? 0.28 : 0.20),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.vpn_key_rounded,
            size: 58,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'تفعيل الاشتراك',
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 56,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'أدخل الرمز لتفعيل المميزات فوراً',
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: color.withOpacity(0.12), height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0088CC).withOpacity(isDark ? 0.22 : 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: isLoading
              ? [
                  const Color(0xFF0088CC).withOpacity(0.75),
                  const Color(0xFF24A1DE).withOpacity(0.75),
                ]
              : const [
                  Color(0xFF0088CC),
                  Color(0xFF24A1DE),
                ],
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'تفعيل',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
