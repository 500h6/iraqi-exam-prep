import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart'; // Import this
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/exams/data/datasources/exam_remote_datasource.dart';
import '../../features/exams/data/repositories/exam_repository_impl.dart';
import '../../features/exams/domain/repositories/exam_repository.dart';
import '../../features/exams/domain/usecases/get_exam_questions_usecase.dart';
import '../../features/exams/domain/usecases/submit_exam_usecase.dart';
import '../../features/exams/presentation/bloc/exam_bloc.dart';
import '../../features/activation/data/datasources/activation_remote_datasource.dart';
import '../../features/activation/data/repositories/activation_repository_impl.dart';
import '../../features/activation/domain/repositories/activation_repository.dart';
import '../../features/activation/domain/usecases/validate_code_usecase.dart';
import '../../features/activation/domain/usecases/check_subscription_usecase.dart';
import '../../features/activation/presentation/bloc/activation_bloc.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/add_question_usecase.dart';
import '../../features/admin/domain/usecases/update_question_usecase.dart';
import '../../features/admin/domain/usecases/delete_question_usecase.dart';
import '../../features/admin/domain/usecases/search_questions_usecase.dart';
import '../../features/admin/presentation/bloc/admin_question_bloc.dart';
import '../theme/bloc/theme_cubit.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // Services
  getIt.registerSingleton<StorageService>(StorageServiceImpl(getIt()));

  // Core
  getIt.registerSingleton<DioClient>(DioClient(getIt()));

  // Auth Feature
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt()),
  );
  getIt.registerSingleton<LogoutUseCase>(LogoutUseCase(getIt()));
  getIt.registerSingleton<CheckAuthStatusUseCase>(CheckAuthStatusUseCase(getIt()));
  getIt.registerSingleton<GetCurrentUserUseCase>(GetCurrentUserUseCase(getIt()));
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt(),
      logoutUseCase: getIt(),
      checkAuthStatusUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
    ),
  );

  // Exam Feature
  getIt.registerSingleton<ExamRemoteDataSource>(
    ExamRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<ExamRepository>(
    ExamRepositoryImpl(getIt()),
  );
  getIt.registerSingleton<GetExamQuestionsUseCase>(GetExamQuestionsUseCase(getIt()));
  getIt.registerSingleton<SubmitExamUseCase>(SubmitExamUseCase(getIt()));
  getIt.registerFactory<ExamBloc>(
    () => ExamBloc(
      getExamQuestionsUseCase: getIt(),
      submitExamUseCase: getIt(),
    ),
  );

  // Activation Feature
  getIt.registerSingleton<ActivationRemoteDataSource>(
    ActivationRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<ActivationRepository>(
    ActivationRepositoryImpl(getIt()),
  );
  getIt.registerSingleton<ValidateCodeUseCase>(ValidateCodeUseCase(getIt()));
  getIt.registerSingleton<CheckSubscriptionUseCase>(CheckSubscriptionUseCase(getIt()));
  getIt.registerFactory<ActivationBloc>(
    () => ActivationBloc(
      validateCodeUseCase: getIt(),
      checkSubscriptionUseCase: getIt(),
    ),
  );

  // Admin Feature
  getIt.registerSingleton<AdminRemoteDataSource>(
    AdminRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<AdminRepository>(
    AdminRepositoryImpl(getIt()),
  );
  getIt.registerSingleton<AddQuestionUseCase>(AddQuestionUseCase(getIt()));
  getIt.registerSingleton<UpdateQuestionUseCase>(UpdateQuestionUseCase(getIt()));
  getIt.registerSingleton<DeleteQuestionUseCase>(DeleteQuestionUseCase(getIt()));
  getIt.registerSingleton<SearchQuestionsUseCase>(SearchQuestionsUseCase(getIt()));
  getIt.registerFactory<AdminQuestionBloc>(
    () => AdminQuestionBloc(
      addQuestionUseCase: getIt(),
      updateQuestionUseCase: getIt(),
      deleteQuestionUseCase: getIt(),
      searchQuestionsUseCase: getIt(),

    ),
  );

  // Theme Feature
  getIt.registerFactory<ThemeCubit>(
    () => ThemeCubit(getIt()),
  );
}
