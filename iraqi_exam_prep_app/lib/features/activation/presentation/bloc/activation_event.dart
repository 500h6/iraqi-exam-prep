import 'package:equatable/equatable.dart';

abstract class ActivationEvent extends Equatable {
  const ActivationEvent();

  @override
  List<Object?> get props => [];
}

class ValidateActivationCodeEvent extends ActivationEvent {
  final String code;

  const ValidateActivationCodeEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class CheckSubscriptionStatusEvent extends ActivationEvent {}
