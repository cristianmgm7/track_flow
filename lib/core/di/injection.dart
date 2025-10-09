import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/utils/app_logger.dart';

// Import the generated config to extend GetIt
import 'injection.config.dart';

// Use the extended GetIt instance with injectable functionality
final GetIt sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  AppLogger.info('Configuring dependencies...', tag: 'DI');
  await sl.init();
  AppLogger.info('Dependencies configured successfully', tag: 'DI');
}

/// Reset all dependencies - useful for testing
Future<void> resetDependencies() async {
  await sl.reset();
}
