import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum AppTab { dashboard, projects, notifications, settings }

@injectable
class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.dashboard);

  void setTab(AppTab tab) => emit(tab);
}
