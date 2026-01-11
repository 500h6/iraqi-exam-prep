import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, phone];
}

class IdentifyEvent extends AuthEvent {
  final String name;
  final String phone;
  final String? branch;
  final String? city;

  const IdentifyEvent({
    required this.name,
    required this.phone,
    this.branch,
    this.city,
  });

  @override
  List<Object?> get props => [name, phone, branch, city];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class UpdateUserEvent extends AuthEvent {
  final UserEntity user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}
