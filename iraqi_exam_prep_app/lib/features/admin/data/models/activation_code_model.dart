import '../../domain/entities/activation_code.dart';

class ActivationCodeModel extends ActivationCode {
  const ActivationCodeModel({
    required super.id,
    required super.code,
    required super.unlockAll,
    required super.subjects,
    required super.maxUses,
    required super.uses,
    super.expiresAt,
    required super.createdAt,
    required super.status,
  });

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) {
    return ActivationCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      unlockAll: json['unlockAll'] as bool? ?? false,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      maxUses: json['maxUses'] as int? ?? 1,
      uses: json['uses'] as int? ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'unlockAll': unlockAll,
        'subjects': subjects,
        'maxUses': maxUses,
        'uses': uses,
        'expiresAt': expiresAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };
}

class GenerateCodeInput {
  final List<String> subjects;
  final bool unlockAll;
  final int maxUses;
  final int? expiresInDays;
  final int count;

  const GenerateCodeInput({
    this.subjects = const [],
    this.unlockAll = false,
    this.maxUses = 1,
    this.expiresInDays,
    this.count = 1,
  });

  Map<String, dynamic> toJson() => {
        'subjects': subjects,
        'unlockAll': unlockAll,
        'maxUses': maxUses,
        if (expiresInDays != null) 'expiresInDays': expiresInDays,
        'count': count,
      };
}
