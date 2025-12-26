import 'package:equatable/equatable.dart';

import '../../domain/entities/activation_code.dart';

abstract class AdminCodeState extends Equatable {
  const AdminCodeState();

  @override
  List<Object?> get props => [];
}

class AdminCodeInitial extends AdminCodeState {}

class AdminCodeLoading extends AdminCodeState {}

class AdminCodeGenerating extends AdminCodeState {}

class AdminCodeGenerated extends AdminCodeState {
  final List<ActivationCode> codes;

  const AdminCodeGenerated(this.codes);

  @override
  List<Object?> get props => [codes];
}

class AdminCodesLoaded extends AdminCodeState {
  final List<ActivationCode> codes;

  const AdminCodesLoaded(this.codes);

  @override
  List<Object?> get props => [codes];
}

class AdminCodeFailure extends AdminCodeState {
  final String message;

  const AdminCodeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminCodeRevoked extends AdminCodeState {}
