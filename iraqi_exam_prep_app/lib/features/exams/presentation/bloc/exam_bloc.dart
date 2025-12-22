import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_exam_questions_usecase.dart';
import '../../domain/usecases/submit_exam_usecase.dart';
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final GetExamQuestionsUseCase getExamQuestionsUseCase;
  final SubmitExamUseCase submitExamUseCase;

  ExamBloc({
    required this.getExamQuestionsUseCase,
    required this.submitExamUseCase,
  }) : super(ExamInitial()) {
    on<LoadExamQuestionsEvent>(_onLoadExamQuestions);
    on<SubmitExamEvent>(_onSubmitExam);
  }

  Future<void> _onLoadExamQuestions(
    LoadExamQuestionsEvent event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    final result = await getExamQuestionsUseCase(event.subject);
    result.fold(
      (failure) => emit(ExamError(failure.message)),
      (questions) => emit(ExamQuestionsLoaded(questions)),
    );
  }

  Future<void> _onSubmitExam(
    SubmitExamEvent event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    final result = await submitExamUseCase(
      subject: event.subject,
      answers: event.answers,
    );
    result.fold(
      (failure) => emit(ExamError(failure.message)),
      (examResult) => emit(ExamSubmitted(examResult)),
    );
  }
}
