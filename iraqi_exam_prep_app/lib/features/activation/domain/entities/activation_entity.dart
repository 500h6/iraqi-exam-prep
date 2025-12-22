import 'package:equatable/equatable.dart';

class ActivationEntity extends Equatable {
  final String code;
  final String status;
  final List<String> subjects;
  final DateTime? expiryDate;

  const ActivationEntity({
    required this.code,
    required this.status,
    required this.subjects,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [code, status, subjects, expiryDate];
}
