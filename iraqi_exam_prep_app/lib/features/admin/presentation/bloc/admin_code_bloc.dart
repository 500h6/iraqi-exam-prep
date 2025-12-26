import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/models/activation_code_model.dart';
import 'admin_code_event.dart';
import 'admin_code_state.dart';

class AdminCodeBloc extends Bloc<AdminCodeEvent, AdminCodeState> {
  final AdminRemoteDataSource dataSource;

  AdminCodeBloc({required this.dataSource}) : super(AdminCodeInitial()) {
    on<GenerateCodesEvent>(_onGenerateCodes);
    on<LoadCodesEvent>(_onLoadCodes);
    on<RevokeCodeEvent>(_onRevokeCode);
    on<ResetAdminCodeEvent>(_onReset);
  }

  Future<void> _onGenerateCodes(
    GenerateCodesEvent event,
    Emitter<AdminCodeState> emit,
  ) async {
    emit(AdminCodeGenerating());
    try {
      final codes = await dataSource.generateCodes(
        GenerateCodeInput(
          subjects: event.subjects,
          unlockAll: event.unlockAll,
          maxUses: event.maxUses,
          expiresInDays: event.expiresInDays,
          count: event.count,
        ),
      );
      emit(AdminCodeGenerated(codes));
    } catch (e) {
      emit(AdminCodeFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadCodes(
    LoadCodesEvent event,
    Emitter<AdminCodeState> emit,
  ) async {
    emit(AdminCodeLoading());
    try {
      final codes = await dataSource.listCodes(
        status: event.status,
        limit: event.limit,
      );
      emit(AdminCodesLoaded(codes));
    } catch (e) {
      emit(AdminCodeFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRevokeCode(
    RevokeCodeEvent event,
    Emitter<AdminCodeState> emit,
  ) async {
    try {
      await dataSource.revokeCode(event.codeId);
      emit(AdminCodeRevoked());
      // Reload codes after revocation
      add(const LoadCodesEvent());
    } catch (e) {
      emit(AdminCodeFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onReset(
    ResetAdminCodeEvent event,
    Emitter<AdminCodeState> emit,
  ) {
    emit(AdminCodeInitial());
  }
}
