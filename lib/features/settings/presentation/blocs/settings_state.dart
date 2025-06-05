import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SigningOut extends SettingsState {}

class SignedOut extends SettingsState {}

class SignOutError extends SettingsState {
  final String message;

  const SignOutError(this.message);
}
