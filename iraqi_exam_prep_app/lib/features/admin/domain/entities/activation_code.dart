import 'package:equatable/equatable.dart';

class ActivationCode extends Equatable {
  final String id;
  final String code;
  final bool unlockAll;
  final List<String> subjects;
  final int maxUses;
  final int uses;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final String status;

  const ActivationCode({
    required this.id,
    required this.code,
    required this.unlockAll,
    required this.subjects,
    required this.maxUses,
    required this.uses,
    this.expiresAt,
    required this.createdAt,
    required this.status,
  });

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isRevoked => status == 'revoked';
  int get remainingUses => maxUses - uses;

  @override
  List<Object?> get props => [
        id,
        code,
        unlockAll,
        subjects,
        maxUses,
        uses,
        expiresAt,
        createdAt,
        status,
      ];
}
