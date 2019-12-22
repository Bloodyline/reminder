import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'core/bloc/app_bloc.dart';
import 'core/data/datasources/c_d_pill_datasource.dart';
import 'core/data/repositories/c_d_db_repo_impl.dart';
import 'core/domain/repositories/c_d_db_repo.dart';
import 'core/usecases/c_app_add_pill_usecase.dart';
import 'core/usecases/c_app_all_pill_usecase.dart';
import 'core/usecases/c_app_get_pill_usecase.dart';
import 'features/login/data/datasources/login_data_source.dart';
import 'features/login/data/repositories/login_repository_impl.dart';
import 'features/login/domain/repositories/login_repository.dart';
import 'features/login/domain/usecases/login_from_cache.dart';
import 'features/login/domain/usecases/login_with_google.dart';
import 'features/login/presentation/bloc/bloc.dart';
import 'features/prescriptions/presentation/bloc/bloc.dart';
import 'features/reminder_schedule/data/repositories/f_reminder_schedule_repo_impl.dart';
import 'features/reminder_schedule/domain/repositories/f_reminder_schedule_repo.dart';
import 'features/reminder_schedule/domain/usecases/f_reminder_schedule_set_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  cApp();

  // Feature Reminder Schedule
  fReminderSchedule();

  // Feature login
  fLogin();

  // Feature Prescriptions
  fPresc();
}

Future<void> cApp() async {
  // Bloc
  sl.registerFactory(
    () => AppBloc(
      loginFromCacheUseCase: sl(),
    ),
  );

  // Usecase
  sl.registerLazySingleton(
    () => CAppAddPillUsecase(sl()),
  );

  sl.registerLazySingleton(
    () => CAppAllPillUsecase(sl()),
  );

  sl.registerLazySingleton(
    () => CAppGetPillUsecase(sl()),
  );

  // Repository
  sl.registerLazySingleton<CDDbRepo>(
    () => CDDbRepoImpl(cdPillDatasource: sl()),
  );

  // Datasource
  sl.registerLazySingleton<CDPillDatasource>(
    () => CDPillDatasourceImpl(),
  );

  // Local Notification
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );
}

Future<void> fReminderSchedule() async {
  // Usecase
  sl.registerLazySingleton(
    () => FReminderScheduleSetUsecase(
      reminderScheduleRepo: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<FReminderScheduleRepo>(
    () => FReminderScheduleRepoImpl(),
  );
}

Future<void> fPresc() async {
  // Bloc
  sl.registerFactory(
    () => PrescriptionsBloc(
      cAppAddPillUsecase: sl(),
      cAppAllPillUsecase: sl(),
      cAppGetPillUsecase: sl(),
    ),
  );
}

Future<void> fLogin() async {
  // Bloc
  sl.registerFactory(
    () => LoginBloc(
      loginWithGoogle: sl(),
    ),
  );

  //Usecase
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton(() => LoginFromCacheUseCase(sl()));

  //Repository
  sl.registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(loginDataSource: sl()));

  //Datasources
  sl.registerLazySingleton<LoginDataSource>(() => LoginDataSourceImpl());
}
