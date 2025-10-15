import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Start watching the dashboard bundle stream
class WatchDashboard extends DashboardEvent {
  const WatchDashboard();
}

/// Stop watching (cleanup)
class StopWatchingDashboard extends DashboardEvent {
  const StopWatchingDashboard();
}


