import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/question_input.dart';
import '../../domain/usecases/add_question_usecase.dart';
import '../../domain/usecases/delete_question_usecase.dart';
import '../../domain/usecases/search_questions_usecase.dart';
import '../../domain/usecases/update_question_usecase.dart';
import 'admin_question_event.dart';
import 'admin_question_state.dart';

class AdminQuestionBloc extends Bloc<AdminQuestionEvent, AdminQuestionState> {
  final AddQuestionUseCase addQuestionUseCase;
  final UpdateQuestionUseCase updateQuestionUseCase;
  final DeleteQuestionUseCase deleteQuestionUseCase;
  final SearchQuestionsUseCase searchQuestionsUseCase;

  AdminQuestionBloc({
    required this.addQuestionUseCase,
    required this.updateQuestionUseCase,
    required this.deleteQuestionUseCase,
    required this.searchQuestionsUseCase,
  }) : super(AdminQuestionInitial()) {
    on<SubmitQuestionEvent>(_onSubmitQuestion);
    on<UpdateAdminQuestionEvent>(_onUpdateQuestion);
    on<DeleteAdminQuestionEvent>(_onDeleteQuestion);
    on<SearchAdminQuestionsEvent>(_onSearchQuestions);
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
        imageUrl: event.imageUrl,
        category: event.category,
      ),
    );
    result.fold(
      (failure) => emit(AdminQuestionFailure(failure.message)),
      (_) => emit(const AdminQuestionSuccess(message: 'تم إضافة السؤال بنجاح')),
    );
  }

  Future<void> _onUpdateQuestion(
    UpdateAdminQuestionEvent event,
    Emitter<AdminQuestionState> emit,
  ) async {
    emit(AdminQuestionLoading());
    final result = await updateQuestionUseCase(
      event.id,
      QuestionInput(
        subject: event.subject,
        questionText: event.questionText,
        options: event.options,
        correctAnswer: event.correctAnswer,
        explanation: event.explanation,
        imageUrl: event.imageUrl,
        category: event.category,
      ),
    );
    result.fold(
      (failure) => emit(AdminQuestionFailure(failure.message)),
      (_) => emit(const AdminQuestionSuccess(message: 'تم تحديث السؤال بنجاح')),
    );
  }

  Future<void> _onDeleteQuestion(
    DeleteAdminQuestionEvent event,
    Emitter<AdminQuestionState> emit,
  ) async {
    emit(AdminQuestionLoading());
    final result = await deleteQuestionUseCase(event.id);
    result.fold(
      (failure) => emit(AdminQuestionFailure(failure.message)),
      (_) => emit(const AdminQuestionSuccess(message: 'تم حذف السؤال بنجاح')),
    );
  }

  Future<void> _onSearchQuestions(
    SearchAdminQuestionsEvent event,
    Emitter<AdminQuestionState> emit,
  ) async {
    emit(AdminQuestionLoading());
    final result = await searchQuestionsUseCase(
      subject: event.subject,
      query: event.query,
    );
    result.fold(
      (failure) => emit(AdminQuestionFailure(failure.message)),
      (questions) => emit(AdminQuestionListSuccess(questions)),
    );
  }

  void _onReset(ResetAdminQuestionEvent event, Emitter<AdminQuestionState> emit) {
    emit(AdminQuestionInitial());
  }
}
