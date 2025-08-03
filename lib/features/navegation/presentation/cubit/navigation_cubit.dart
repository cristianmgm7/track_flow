import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/common/interfaces/resetable.dart';
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart';
import 'package:trackflow/core/di/injection.dart';

enum AppTab { projects, notifications, settings }

@injectable
class NavigationCubit extends Cubit<AppTab> implements Resetable {
  NavigationCubit() : super(AppTab.projects) {
    // Register for automatic state cleanup
    final cleanupService = sl<BlocStateCleanupService>();
    cleanupService.registerResetable(this);
  }

  void setTab(AppTab tab) => emit(tab);

  @override
  void onChange(Change<AppTab> change) {
    super.onChange(change);
  }

  @override
  void reset() => emit(AppTab.projects);

  @override
  Future<void> close() {
    // Unregister from cleanup service
    try {
      final cleanupService = sl<BlocStateCleanupService>();
      cleanupService.unregisterResetable(this);
    } catch (e) {
      // Service might be disposed, ignore
    }
    return super.close();
  }
}
