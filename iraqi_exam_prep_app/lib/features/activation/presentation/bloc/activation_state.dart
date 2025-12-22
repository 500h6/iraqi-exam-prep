import 'package:equatable/equatable.dart';

abstract class ActivationState extends Equatable {
  const ActivationState();

  @override
  List<Object?> get props => [];
}

class ActivationInitial extends ActivationState {}

class ActivationLoading extends ActivationState {}

class ActivationSuccess extends ActivationState {
  final String message;

  const ActivationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ActivationError extends ActivationState {
  final String message;

  const ActivationError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubscriptionActive extends ActivationState {}

class SubscriptionInactive extends ActivationState {}
