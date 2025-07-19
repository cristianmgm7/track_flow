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

// Register ProjectDetailBloc and WatchProjectDetailUseCase
// If using injectable, annotate ProjectDetailBloc and WatchProjectDetailUseCase with @injectable or @lazySingleton as needed.
// If using manual registration, add:
// getIt.registerFactory(() => ProjectDetailBloc(watchProjectDetail: getIt()));
// getIt.registerLazySingleton(() => WatchProjectDetailUseCase(...));
