import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/di/injection.config.dart';
import 'package:trackflow/core/coordination/app_flow_bloc.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecase.dart';
import 'package:trackflow/features/onboarding/domain/usecases/onboarding_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/check_profile_completeness_usecase.dart';

final GetIt sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => sl.init();

/// Reset all dependencies - useful for testing
Future<void> resetDependencies() async {
  await sl.reset();
}

// Register AppFlowBloc and use cases manually
// If using injectable, annotate ProjectDetailBloc and WatchProjectDetailUseCase with @injectable or @lazySingleton as needed.
// If using manual registration, add:
// getIt.registerFactory(() => ProjectDetailBloc(watchProjectDetail: getIt()));
// getIt.registerLazySingleton(() => WatchProjectDetailUseCase(...));

// Manual registration for AppFlowBloc and use cases
// Future<void> registerAppFlowDependencies() async {
//   // Register use cases
//   sl.registerLazySingleton(() => AuthUseCase(sl()));
//   sl.registerLazySingleton(() => OnboardingUseCase(sl()));
//   sl.registerLazySingleton(() => CheckProfileCompletenessUseCase(sl()));

//   // Register AppFlowBloc
//   sl.registerFactory(
//     () => AppFlowBloc(
//       authUseCase: sl(),
//       onboardingUseCase: sl(),
//       profileUseCase: sl(),
//     ),
//   );
// }
