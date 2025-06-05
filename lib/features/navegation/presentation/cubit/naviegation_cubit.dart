import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum AppTab { dashboard, projects, notifications, settings }

@injectable
class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.dashboard);

  void setTab(AppTab tab) => emit(tab);

  @override
  void onChange(Change<AppTab> change) {
    super.onChange(change);
    debugPrint('onChange: from ${change.currentState} to ${change.nextState}');
  }
}
