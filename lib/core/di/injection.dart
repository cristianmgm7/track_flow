import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/di/injection.config.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart';

final GetIt sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => sl.init();

// Register ProjectDetailBloc and WatchProjectDetailUseCase
// If using injectable, annotate ProjectDetailBloc and WatchProjectDetailUseCase with @injectable or @lazySingleton as needed.
// If using manual registration, add:
// getIt.registerFactory(() => ProjectDetailBloc(watchProjectDetail: getIt()));
// getIt.registerLazySingleton(() => WatchProjectDetailUseCase(...));
