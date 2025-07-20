import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/di/injection.config.dart';

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
