import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithPhoneEvent extends AuthEvent {
  final String phone;

  const LoginWithPhoneEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String code;

  const VerifyOtpEvent({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}

class CompleteProfileEvent extends AuthEvent {
  final String name;

  const CompleteProfileEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class UpdateUserEvent extends AuthEvent {
  final UserEntity user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}
