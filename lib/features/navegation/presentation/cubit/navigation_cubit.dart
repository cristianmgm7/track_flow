import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum AppTab { projects, myMusic }

@injectable
class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.projects);

  void setTab(AppTab tab) => emit(tab);

  @override
  void onChange(Change<AppTab> change) {
    super.onChange(change);
  }

  void reset() => emit(AppTab.projects);
}
