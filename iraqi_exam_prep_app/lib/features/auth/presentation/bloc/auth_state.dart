import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phone;
  const AuthOtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class AuthUnlinked extends AuthState {
  final String phone;
  const AuthUnlinked(this.phone);

  @override
  List<Object?> get props => [phone];
}

class AuthProfileIncomplete extends AuthState {
  final UserEntity user;
  const AuthProfileIncomplete(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
