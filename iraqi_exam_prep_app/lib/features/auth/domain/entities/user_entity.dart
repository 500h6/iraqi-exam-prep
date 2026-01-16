import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final bool isPremium;
  final List<String> unlockedSubjects;
  final DateTime createdAt;
  final String role;

  const UserEntity({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    required this.isPremium,
    required this.unlockedSubjects,
    required this.createdAt,
    required this.role,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        name,
        isPremium,
        unlockedSubjects,
        createdAt,
        role,
      ];
}
