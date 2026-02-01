import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/modern_section.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with TickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendSeconds = 45;

  final _formKey = GlobalKey<FormState>();

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  // Page entrance animation
  late final AnimationController _pageAnim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Micro-interactions
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  bool _showSuccessBanner = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  bool get _isOtpComplete => _otp.length == _otpLength;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _pageAnim = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageAnim, curve: Curves.easeOutCubic));

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    _pageAnim.forward();
    _startTimer();
    _setupClipboardListener();
  }

  void _setupClipboardListener() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && mounted) {
        final text = data!.text!;
        final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
        
        // لصق تلقائي بدون dialog
        if (digitsOnly.length == _otpLength) {
          _pasteCode(digitsOnly);
        }
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  void _pasteCode(String code) {
    if (code.length == _otpLength) {
      for (int k = 0; k < _otpLength; k++) {
        _controllers[k].text = code[k];
      }
      HapticFeedback.mediumImpact();
      _bumpSuccessBanner();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _pageAnim.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _showSuccessBanner = false);
    _focusNodes.first.requestFocus();
  }

  void _bumpSuccessBanner() {
    if (!mounted) return;
    setState(() => _showSuccessBanner = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _showSuccessBanner = false);
    });
  }

  void _shake() {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }

  void _verifyOtp({required bool isLoading}) {
    FocusScope.of(context).unfocus();

    if (isLoading) return;

    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              phone: widget.phone,
              code: _otp,
            ),
          );
    } else {
      _shake();
    }
  }



  void _resend() {
    if (_secondsLeft != 0) return;
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(LoginWithPhoneEvent(widget.phone));
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        
        // Responsive breakpoints
        final isTablet = constraints.maxWidth > 600;
        final isSmallPhone = constraints.maxHeight < 700;
        final maxWidth = isTablet ? 500.0 : double.infinity;

        final textPrimary = _isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final textSecondary = _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'التحقق من الرمز',
              style: TextStyle(fontSize: isSmallPhone ? 16 : 18),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  cs.primary.withOpacity(_isDark ? 0.08 : 0.06),
                ],
              ),
            ),
            child: BlocConsumer<AuthBloc, AuthState>(
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
                  _clearOtp();
                  _shake();
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 20,
                          vertical: isSmallPhone ? 12 : 16,
                        ),
                        child: FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slide,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: isSmallPhone ? 4 : 8),

                                  _buildTopIcon(isSmallPhone, isTablet),

                                  SizedBox(height: isSmallPhone ? 12 : 16),

                                  Text(
                                    'أدخل الرمز الذي وصلك عبر واتساب',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                      fontSize: _getResponsiveFontSize(
                                        isSmallPhone: isSmallPhone,
                                        isTablet: isTablet,
                                        small: 18,
                                        normal: 22,
                                        tablet: 26,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isSmallPhone ? 6 : 8),
                                  Text(
                                    'تم إرسال الرمز إلى الرقم ${widget.phone}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: textSecondary,
                                      height: 1.4,
                                      fontSize: _getResponsiveFontSize(
                                        isSmallPhone: isSmallPhone,
                                        isTablet: isTablet,
                                        small: 13,
                                        normal: 14,
                                        tablet: 16,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: isSmallPhone ? 12 : 16),

                                  // Success banner
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    child: _showSuccessBanner
                                        ? _SuccessBanner(
                                            isDark: _isDark,
                                            text: 'تم إدخال الرمز ✅ جاري التحقق...',
                                            isSmallPhone: isSmallPhone,
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  if (_showSuccessBanner) 
                                    SizedBox(height: isSmallPhone ? 8 : 12),

                                  if (state is AuthUnlinked) ...[
                                    ModernSection(
                                      title: 'تنبيه',
                                      icon: Icons.person_off_rounded,
                                      color: AppColors.error,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'رقم الهاتف غير مسجل',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                              fontSize: _getResponsiveFontSize(
                                                isSmallPhone: isSmallPhone,
                                                isTablet: isTablet,
                                                small: 14,
                                                normal: 15,
                                                tablet: 17,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: isSmallPhone ? 6 : 8),
                                          Text(
                                            'هذا الرقم غير مرتبط بأي حساب. يرجى التأكد من الرقم أو الاتصال بالدعم.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              height: 1.5,
                                              color: textSecondary,
                                              fontSize: _getResponsiveFontSize(
                                                isSmallPhone: isSmallPhone,
                                                isTablet: isTablet,
                                                small: 12,
                                                normal: 13,
                                                tablet: 15,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: isSmallPhone ? 10 : 12),
                                          _OutlineButton(
                                            label: 'العودة لتسجيل الدخول',
                                            icon: Icons.arrow_back,
                                            color: cs.primary,
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              context.pop();
                                            },
                                            isSmallPhone: isSmallPhone,
                                            isTablet: isTablet,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: isSmallPhone ? 12 : 16),
                                  ],

                                  ModernSection(
                                    title: 'رمز التحقق',
                                    icon: Icons.password_rounded,
                                    color: cs.primary,
                                    child: AnimatedBuilder(
                                      animation: _shakeAnim,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(_shakeAnim.value, 0),
                                          child: child,
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          _OtpBoxes(
                                            controllers: _controllers,
                                            focusNodes: _focusNodes,
                                            isDark: _isDark,
                                            isSmallPhone: isSmallPhone,
                                            isTablet: isTablet,
                                            screenWidth: constraints.maxWidth,
                                            onDigit: () => HapticFeedback.selectionClick(),
                                            onCompleted: (code) {
                                              _bumpSuccessBanner();
                                              _verifyOtp(isLoading: isLoading);
                                            },
                                            onPasteRequest: _pasteCode,
                                          ),
                                          SizedBox(height: isSmallPhone ? 10 : 12),
                                          _buildTimerSection(
                                            theme,
                                            textSecondary,
                                            cs,
                                            isSmallPhone,
                                            isTablet,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isSmallPhone ? 14 : 18),

                                  AppButton(
                                    isLoading: isLoading,
                                    onPressed: isLoading
                                        ? null
                                        : () => _verifyOtp(isLoading: isLoading),
                                    text: 'تحقق وتسجيل الدخول',
                                    icon: Icons.check_circle_rounded,
                                  ),

                                  SizedBox(height: isSmallPhone ? 10 : 12),

                                  _buildActionButtons(
                                    textSecondary,
                                    isLoading,
                                    isSmallPhone,
                                    isTablet,
                                  ),
                                  
                                  SizedBox(height: isSmallPhone ? 8 : 12),
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
            ),
          ),
        );
      },
    );
  }

  double _getResponsiveFontSize({
    required bool isSmallPhone,
    required bool isTablet,
    required double small,
    required double normal,
    required double tablet,
  }) {
    if (isTablet) return tablet;
    if (isSmallPhone) return small;
    return normal;
  }

  Widget _buildTopIcon(bool isSmallPhone, bool isTablet) {
    final iconSize = isTablet ? 100.0 : (isSmallPhone ? 64.0 : 80.0);
    final iconInnerSize = isTablet ? 50.0 : (isSmallPhone ? 32.0 : 40.0);

    return Center(
      child: Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: (_isDark ? AppColors.primaryLight : AppColors.primary)
              .withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: (_isDark ? AppColors.primaryLight : AppColors.primary)
                .withOpacity(0.22),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.verified_user_rounded,
          size: iconInnerSize,
          color: _isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTimerSection(
    ThemeData theme,
    Color textSecondary,
    ColorScheme cs,
    bool isSmallPhone,
    bool isTablet,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Icon(
          Icons.timer_rounded,
          size: _getResponsiveFontSize(
            isSmallPhone: isSmallPhone,
            isTablet: isTablet,
            small: 15,
            normal: 17,
            tablet: 19,
          ),
          color: textSecondary,
        ),
        Text(
          _secondsLeft == 0
              ? 'يمكنك إعادة الإرسال الآن'
              : 'إعادة الإرسال خلال ${_secondsLeft}s',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: _getResponsiveFontSize(
              isSmallPhone: isSmallPhone,
              isTablet: isTablet,
              small: 11,
              normal: 13,
              tablet: 15,
            ),
          ),
        ),
        TextButton(
          onPressed: _secondsLeft == 0 ? _resend : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 10 : 8,
              vertical: 4,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'إعادة إرسال',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _getResponsiveFontSize(
                isSmallPhone: isSmallPhone,
                isTablet: isTablet,
                small: 11,
                normal: 13,
                tablet: 15,
              ),
              color: _secondsLeft == 0
                  ? (_isDark ? AppColors.primaryLight : Theme.of(context).colorScheme.primary)
                  : textSecondary.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    Color textSecondary,
    bool isLoading,
    bool isSmallPhone,
    bool isTablet,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            _clearOtp();
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 10 : 8,
            ),
          ),
          icon: Icon(
            Icons.backspace_outlined,
            color: textSecondary,
            size: _getResponsiveFontSize(
              isSmallPhone: isSmallPhone,
              isTablet: isTablet,
              small: 15,
              normal: 17,
              tablet: 19,
            ),
          ),
          label: Text(
            'مسح الرمز',
            style: TextStyle(
              color: textSecondary,
              fontSize: _getResponsiveFontSize(
                isSmallPhone: isSmallPhone,
                isTablet: isTablet,
                small: 12,
                normal: 13,
                tablet: 15,
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 10 : 8,
            ),
          ),
          icon: Icon(
            Icons.edit_rounded,
            color: textSecondary,
            size: _getResponsiveFontSize(
              isSmallPhone: isSmallPhone,
              isTablet: isTablet,
              small: 15,
              normal: 17,
              tablet: 19,
            ),
          ),
          label: Text(
            'تعديل الرقم',
            style: TextStyle(
              color: textSecondary,
              fontSize: _getResponsiveFontSize(
                isSmallPhone: isSmallPhone,
                isTablet: isTablet,
                small: 12,
                normal: 13,
                tablet: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ====================== Success Banner ======================

class _SuccessBanner extends StatelessWidget {
  final bool isDark;
  final String text;
  final bool isSmallPhone;

  const _SuccessBanner({
    required this.isDark,
    required this.text,
    required this.isSmallPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('success_banner'),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 12 : 14,
        vertical: isSmallPhone ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.success.withOpacity(isDark ? 0.38 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: isSmallPhone ? 18 : 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: isSmallPhone ? 12 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== OTP Boxes ======================

class _OtpBoxes extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isDark;
  final bool isSmallPhone;
  final bool isTablet;
  final double screenWidth;
  final VoidCallback onDigit;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String> onPasteRequest;

  const _OtpBoxes({
    required this.controllers,
    required this.focusNodes,
    required this.isDark,
    required this.isSmallPhone,
    required this.isTablet,
    required this.screenWidth,
    required this.onDigit,
    required this.onCompleted,
    required this.onPasteRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // حساب حجم المربع بناءً على عرض الشاشة - تحسين أفضل
    final horizontalPadding = isTablet ? 64.0 : 40.0;
    final availableWidth = screenWidth - horizontalPadding;
    
    // مسافات أصغر للشاشات الصغيرة
    final spacing = isSmallPhone ? 3.0 : (isTablet ? 10.0 : 6.0);
    final totalSpacing = spacing * (controllers.length - 1);
    final calculatedBoxWidth = (availableWidth - totalSpacing) / controllers.length;
    
    // تحديد حجم مناسب للمربع مع ضمان عدم الخروج
    final boxWidth = calculatedBoxWidth.clamp(
      isSmallPhone ? 36.0 : 40.0,
      isTablet ? 58.0 : 48.0,
    );

    return FormField<String>(
      validator: (_) {
        final code = controllers.map((c) => c.text.trim()).join();
        if (code.length != controllers.length) {
          return 'الرمز يجب أن يتكون من 6 أرقام';
        }
        return null;
      },
      builder: (state) {
        return Column(
          children: [
            // زر اللصق السريع
            Padding(
              padding: EdgeInsets.only(bottom: isSmallPhone ? 10 : 12),
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      final digitsOnly = data!.text!.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digitsOnly.length == controllers.length) {
                        onPasteRequest(digitsOnly);
                      } else {
                        Fluttertoast.showToast(
                          msg: 'الرمز في الحافظة غير صحيح',
                          backgroundColor: AppColors.error,
                        );
                      }
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'فشل قراءة الحافظة',
                      backgroundColor: AppColors.error,
                    );
                  }
                },
                icon: Icon(
                  Icons.content_paste_rounded,
                  size: isSmallPhone ? 15 : (isTablet ? 19 : 17),
                ),
                label: Text(
                  'لصق الرمز من الحافظة',
                  style: TextStyle(
                    fontSize: isSmallPhone ? 11 : (isTablet ? 15 : 13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                ),
              ),
            ),
            
            // مربعات OTP في سطر واحد - محسّن
            Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(controllers.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: i < controllers.length - 1 ? spacing : 0,
                          ),
                          child: _OtpBox(
                            controller: controllers[i],
                            focusNode: focusNodes[i],
                            isDark: isDark,
                            autoFocus: i == 0,
                            boxWidth: boxWidth,
                            boxHeight: isSmallPhone ? 42.0 : (isTablet ? 58.0 : 48.0),
                            fontSize: isSmallPhone ? 15.0 : (isTablet ? 24.0 : 19.0),
                            onChanged: (v) {
                              final value = v.trim();
                              if (value.isNotEmpty) {
                                onDigit();
                                if (i < controllers.length - 1) {
                                  focusNodes[i + 1].requestFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                  final code = controllers.map((c) => c.text.trim()).join();
                                  if (code.length == controllers.length) {
                                    onCompleted(code);
                                  }
                                }
                              }
                              state.didChange(value);
                            },
                            onBackspaceAtEmpty: () {
                              if (i > 0) {
                                controllers[i - 1].clear();
                                focusNodes[i - 1].requestFocus();
                                state.didChange('');
                              }
                            },
                            onPaste: (pasted) {
                              final digitsOnly = pasted.replaceAll(RegExp(r'[^0-9]'), '');
                              if (digitsOnly.length == controllers.length) {
                                for (int k = 0; k < controllers.length; k++) {
                                  controllers[k].text = digitsOnly[k];
                                }
                                FocusScope.of(context).unfocus();
                                onCompleted(digitsOnly);
                                state.didChange(digitsOnly);
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            if (state.hasError) ...[
              SizedBox(height: isSmallPhone ? 8 : 10),
              Text(
                state.errorText ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: isSmallPhone ? 10 : (isTablet ? 13 : 11),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final bool autoFocus;
  final double boxWidth;
  final double boxHeight;
  final double fontSize;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceAtEmpty;
  final ValueChanged<String> onPaste;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.autoFocus,
    required this.boxWidth,
    required this.boxHeight,
    required this.fontSize,
    required this.onChanged,
    required this.onBackspaceAtEmpty,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? AppColors.backgroundDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: RawKeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKey: (e) {
          if (e is RawKeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspaceAtEmpty();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autoFocus,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: fontSize,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: bg,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (v) {
            if (v.length > 1) {
              onPaste(v);
              return;
            }
            onChanged(v);
          },
        ),
      ),
    );
  }
}

// ====================== Buttons ======================

class _PrimaryGradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final bool isSmallPhone;
  final bool isTablet;

  const _PrimaryGradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.gradient,
    required this.isSmallPhone,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = isTablet ? 56.0 : (isSmallPhone ? 46.0 : 50.0);

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF0088CC))
                      .withOpacity(isDark ? 0.25 : 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isTablet ? 22 : (isSmallPhone ? 18 : 20),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : (isSmallPhone ? 13 : 14),
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isSmallPhone;
  final bool isTablet;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.isSmallPhone,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = isTablet ? 54.0 : (isSmallPhone ? 44.0 : 48.0);

    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        icon: Icon(
          icon,
          size: isTablet ? 20 : (isSmallPhone ? 17 : 18),
        ),
        label: Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: isTablet ? 15 : (isSmallPhone ? 12 : 13),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryLight : color,
          side: BorderSide(
            color: isDark ? AppColors.primaryLight : color,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}