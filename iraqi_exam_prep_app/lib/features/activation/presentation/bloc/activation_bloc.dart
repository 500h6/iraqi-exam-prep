import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/validate_code_usecase.dart';
import '../../domain/usecases/check_subscription_usecase.dart';
import 'activation_event.dart';
import 'activation_state.dart';

class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  final ValidateCodeUseCase validateCodeUseCase;
  final CheckSubscriptionUseCase checkSubscriptionUseCase;

  ActivationBloc({
    required this.validateCodeUseCase,
    required this.checkSubscriptionUseCase,
  }) : super(ActivationInitial()) {
    on<ValidateActivationCodeEvent>(_onValidateCode);
    on<CheckSubscriptionStatusEvent>(_onCheckSubscription);
  }

  Future<void> _onValidateCode(
    ValidateActivationCodeEvent event,
    Emitter<ActivationState> emit,
  ) async {
    emit(ActivationLoading());
    final result = await validateCodeUseCase(event.code);
    result.fold(
      (failure) => emit(ActivationError(failure.message)),
      (user) {
        emit(ActivationSuccess(
          'Activation successful! Premium features unlocked.',
          user,
        ));
      },
    );
  }

  Future<void> _onCheckSubscription(
    CheckSubscriptionStatusEvent event,
    Emitter<ActivationState> emit,
  ) async {
    emit(ActivationLoading());
    final result = await checkSubscriptionUseCase();
    result.fold(
      (failure) => emit(ActivationError(failure.message)),
      (isActive) => emit(isActive ? SubscriptionActive() : SubscriptionInactive()),
    );
  }
}
