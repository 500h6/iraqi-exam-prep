import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/question_input.dart';
import '../../domain/usecases/add_question_usecase.dart';
import 'admin_question_event.dart';
import 'admin_question_state.dart';

class AdminQuestionBloc extends Bloc<AdminQuestionEvent, AdminQuestionState> {
  final AddQuestionUseCase addQuestionUseCase;

  AdminQuestionBloc({required this.addQuestionUseCase})
      : super(AdminQuestionInitial()) {
    on<SubmitQuestionEvent>(_onSubmitQuestion);
    on<ResetAdminQuestionEvent>(_onReset);
  }

  Future<void> _onSubmitQuestion(
    SubmitQuestionEvent event,
    Emitter<AdminQuestionState> emit,
  ) async {
    emit(AdminQuestionLoading());
    final result = await addQuestionUseCase(
      QuestionInput(
        subject: event.subject,
        questionText: event.questionText,
        options: event.options,
        correctAnswer: event.correctAnswer,
        explanation: event.explanation,
      ),
    );
    result.fold(
      (failure) => emit(AdminQuestionFailure(failure.message)),
      (_) => emit(AdminQuestionSuccess()),
    );
  }

  void _onReset(
    ResetAdminQuestionEvent event,
    Emitter<AdminQuestionState> emit,
  ) {
    emit(AdminQuestionInitial());
  }
}
