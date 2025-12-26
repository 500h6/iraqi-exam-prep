import 'package:equatable/equatable.dart';

abstract class AdminCodeEvent extends Equatable {
  const AdminCodeEvent();

  @override
  List<Object?> get props => [];
}

class GenerateCodesEvent extends AdminCodeEvent {
  final List<String> subjects;
  final bool unlockAll;
  final int maxUses;
  final int? expiresInDays;
  final int count;

  const GenerateCodesEvent({
    this.subjects = const [],
    this.unlockAll = false,
    this.maxUses = 1,
    this.expiresInDays,
    this.count = 1,
  });

  @override
  List<Object?> get props => [subjects, unlockAll, maxUses, expiresInDays, count];
}

class LoadCodesEvent extends AdminCodeEvent {
  final String? status;
  final int? limit;

  const LoadCodesEvent({this.status, this.limit});

  @override
  List<Object?> get props => [status, limit];
}

class RevokeCodeEvent extends AdminCodeEvent {
  final String codeId;

  const RevokeCodeEvent(this.codeId);

  @override
  List<Object?> get props => [codeId];
}

class ResetAdminCodeEvent extends AdminCodeEvent {}
