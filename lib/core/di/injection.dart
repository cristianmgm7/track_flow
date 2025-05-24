import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/di/injection.config.dart';

final GetIt sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => sl.init();
