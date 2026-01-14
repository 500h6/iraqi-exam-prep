import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.authRepository,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginWithPhoneEvent>(_onLoginWithPhone);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CompleteProfileEvent>(_onCompleteProfile);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateUserEvent>((event, emit) => emit(AuthAuthenticated(event.user)));
  }

  Future<void> _onLoginWithPhone(LoginWithPhoneEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // For simplicity, calling repository directly. Ideally use UseCase.
    final result = await authRepository.requestOtp(phone: event.phone);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) {
        final linked = data['linked'] as bool? ?? false;
        if (linked) {
          emit(AuthOtpSent(event.phone));
        } else {
          emit(AuthUnlinked(event.phone));
        }
      },
    );
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(phone: event.phone, code: event.code);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
         // Check if name is placeholder "New Student"
         if (user.name == "New Student") {
             emit(AuthProfileIncomplete(user));
         } else {
             emit(AuthAuthenticated(user));
         }
      },
    );
  }

  Future<void> _onCompleteProfile(CompleteProfileEvent event, Emitter<AuthState> emit) async {
      emit(AuthLoading());
      final result = await authRepository.completeProfile(name: event.name);
      result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
      );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // 1. Check if we have a token
    final statusResult = await checkAuthStatusUseCase();
    
    await statusResult.fold(
      (failure) async {
        emit(AuthUnauthenticated());
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          // 2. We have a token, now fetch the full profile
          final userResult = await getCurrentUserUseCase();
          userResult.fold(
            (failure) => emit(AuthUnauthenticated()),
            (user) => emit(AuthAuthenticated(user)),
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
}
