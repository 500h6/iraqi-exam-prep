import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      context.read<AuthBloc>().add(
            LoginWithPhoneEvent(_phoneController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            context.push('/otp', extra: state.phone);
          } else if (state is AuthUnlinked) {
            context.push('/otp', extra: state.phone);
          } else if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: AppColors.error,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),
                        
                        // Logo with gradient background
                        _buildLogo(),
                        const SizedBox(height: 40),
                        
                        // Title & Subtitle
                        _buildHeader(),
                        const SizedBox(height: 48),
                        
                        // Phone Input Card
                        _buildPhoneInputCard(),
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        _buildSubmitButton(state),
                        const SizedBox(height: 40),
                        
                        // Bottom Decoration
                        _buildBottomInfo(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.school_rounded,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'مرحباً بك 👋',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: _isDarkMode 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أدخل رقم هاتفك للتسجيل أو الدخول إلى حسابك',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode 
                ? Colors.black.withValues(alpha: 0.2) 
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'رقم الهاتف',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Phone Input Field
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              hintText: '07xxxxxxxx',
              hintStyle: TextStyle(
                color: _isDarkMode 
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 18,
                letterSpacing: 1.2,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12, left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: (_isDarkMode ? AppColors.primaryLight : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.phone_android_rounded,
                  color: _isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  size: 22,
                ),
              ),
              filled: true,
              fillColor: _isDarkMode 
                  ? AppColors.backgroundDark 
                  : AppColors.surfaceLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _isDarkMode ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              if (value.length < 10) {
                return 'رقم الهاتف قصير جداً';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AuthState state) {
    final isLoading = state is AuthLoading;

    return SizedBox(
      height: 58,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => _submit(context),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isLoading
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
              color: isLoading 
                  ? (_isDarkMode 
                      ? AppColors.surfaceDark 
                      : AppColors.surfaceLight)
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                          _isDarkMode ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'متابعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              color: _isDarkMode ? AppColors.borderDark : AppColors.border,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.security_rounded,
                size: 18,
                color: _isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
              ),
            ),
            Container(
              width: 40,
              height: 1,
              color: _isDarkMode ? AppColors.borderDark : AppColors.border,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'بياناتك محمية ولن يتم مشاركتها',
          style: TextStyle(
            fontSize: 13,
            color: _isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
