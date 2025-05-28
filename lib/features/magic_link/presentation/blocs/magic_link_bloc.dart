import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart';
import 'magic_link_events.dart';
import 'magic_link_states.dart';

@injectable
class MagicLinkBloc extends Bloc<MagicLinkEvent, MagicLinkState> {
  final GenerateMagicLinkUseCase generateMagicLink;
  final ValidateMagicLinkUseCase validateMagicLink;
  final ConsumeMagicLinkUseCase consumeMagicLink;
  final ResendMagicLinkUseCase resendMagicLink;
  final GetMagicLinkStatusUseCase getMagicLinkStatus;

  MagicLinkBloc({
    required this.generateMagicLink,
    required this.validateMagicLink,
    required this.consumeMagicLink,
    required this.resendMagicLink,
    required this.getMagicLinkStatus,
  }) : super(MagicLinkInitial()) {
    on<MagicLinkRequested>(_onMagicLinkRequested);
    on<MagicLinkValidated>(_onMagicLinkValidated);
    on<MagicLinkConsumed>(_onMagicLinkConsumed);
    on<MagicLinkResent>(_onMagicLinkResent);
    on<MagicLinkStatusChecked>(_onMagicLinkStatusChecked);
  }

  Future<void> _onMagicLinkRequested(
    MagicLinkRequested event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await generateMagicLink(
      GenerateMagicLinkParams(email: event.email),
    );
    result.fold(
      (failure) => emit(MagicLinkGenerationError(error: failure)),
      (magicLink) => emit(MagicLinkGeneratedSuccess(linkId: magicLink.id)),
    );
  }

  Future<void> _onMagicLinkValidated(
    MagicLinkValidated event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await validateMagicLink(
      ValidateMagicLinkParams(linkId: event.linkId),
    );
    result.fold(
      (failure) => emit(MagicLinkValidationError(error: failure)),
      (_) => emit(MagicLinkValidatedSuccess()),
    );
  }

  Future<void> _onMagicLinkConsumed(
    MagicLinkConsumed event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await consumeMagicLink(
      ConsumeMagicLinkParams(linkId: event.linkId),
    );
    result.fold(
      (failure) => emit(MagicLinkConsumedError(error: failure)),
      (_) => emit(MagicLinkConsumedSuccess()),
    );
  }

  Future<void> _onMagicLinkResent(
    MagicLinkResent event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await resendMagicLink(
      ResendMagicLinkParams(email: event.email),
    );
    result.fold(
      (failure) => emit(MagicLinkResendError(error: failure)),
      (_) => emit(MagicLinkResentSuccess()),
    );
  }

  Future<void> _onMagicLinkStatusChecked(
    MagicLinkStatusChecked event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await getMagicLinkStatus(
      GetMagicLinkStatusParams(linkId: event.linkId),
    );
    result.fold(
      (failure) => emit(MagicLinkStatusError(error: failure)),
      (status) => emit(MagicLinkStatusLoaded(status: status)),
    );
  }
}
