import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/magic_link/domain/usecases/generate_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/resend_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/get_magic_link_status_use_case.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/join_project_with_id_usecase.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'magic_link_events.dart';
import 'magic_link_states.dart';
import 'package:trackflow/core/error/failures.dart';

@injectable
class MagicLinkBloc extends Bloc<MagicLinkEvent, MagicLinkState> {
  final GenerateMagicLinkUseCase generateMagicLink;
  final ValidateMagicLinkUseCase validateMagicLink;
  final ConsumeMagicLinkUseCase consumeMagicLink;
  final ResendMagicLinkUseCase resendMagicLink;
  final GetMagicLinkStatusUseCase getMagicLinkStatus;
  final JoinProjectWithIdUseCase joinProjectWithId;
  final AuthRepository authRepository;

  MagicLinkBloc({
    required this.generateMagicLink,
    required this.validateMagicLink,
    required this.consumeMagicLink,
    required this.resendMagicLink,
    required this.getMagicLinkStatus,
    required this.joinProjectWithId,
    required this.authRepository,
  }) : super(MagicLinkInitial()) {
    on<MagicLinkRequested>(_onMagicLinkRequested);
    on<MagicLinkValidated>(_onMagicLinkValidated);
    on<MagicLinkConsumed>(_onMagicLinkConsumed);
    on<MagicLinkResent>(_onMagicLinkResent);
    on<MagicLinkStatusChecked>(_onMagicLinkStatusChecked);
    on<MagicLinkHandleRequested>(_onMagicLinkHandleRequested);
  }

  Future<void> _onMagicLinkRequested(
    MagicLinkRequested event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await generateMagicLink(
      GenerateMagicLinkParams(projectId: event.projectId),
    );
    result.fold(
      (failure) => emit(MagicLinkGenerationError(error: failure)),
      (magicLink) => emit(MagicLinkGeneratedSuccess(linkUrl: magicLink.url)),
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
      (magicLink) => emit(MagicLinkValidatedSuccess(magicLink)),
    );
  }

  Future<void> _onMagicLinkConsumed(
    MagicLinkConsumed event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkLoading());
    final result = await consumeMagicLink(
      ConsumeMagicLinkParams(token: event.linkId),
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
      ResendMagicLinkParams(linkId: event.linkId),
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

  Future<void> _onMagicLinkHandleRequested(
    MagicLinkHandleRequested event,
    Emitter<MagicLinkState> emit,
  ) async {
    emit(MagicLinkHandling());
    // 1. Validar el magic link
    final validateResult = await validateMagicLink(
      ValidateMagicLinkParams(linkId: event.token),
    );
    if (validateResult.isLeft()) {
      emit(
        MagicLinkHandleErrorState(
          error: validateResult.swap().getOrElse(() => ServerFailure('Error')),
        ),
      );
      return;
    }
    final magicLink = validateResult.getOrElse(() => throw Exception());
    // 2. Verificar autenticación
    final userIdOrFailure = await authRepository.getSignedInUserId();
    if (userIdOrFailure.isLeft()) {
      emit(
        MagicLinkHandleErrorState(
          error: userIdOrFailure.swap().getOrElse(
            () => ServerFailure('No user'),
          ),
        ),
      );
      return;
    }
    final consumeResult = await consumeMagicLink(
      ConsumeMagicLinkParams(token: event.token),
    );
    if (consumeResult.isLeft()) {
      emit(
        MagicLinkHandleErrorState(
          error: consumeResult.swap().getOrElse(() => ServerFailure('Error')),
        ),
      );
      return;
    }
    // 4. Agregar usuario al proyecto
    final addResult = await joinProjectWithId(
      JoinProjectWithIdParams(
        projectId: ProjectId.fromUniqueString(magicLink.projectId),
      ),
    );
    if (addResult.isLeft()) {
      emit(
        MagicLinkHandleErrorState(
          error: addResult.swap().getOrElse(() => ServerFailure('Error')),
        ),
      );
      return;
    }
    emit(MagicLinkHandleSuccessState());
  }
}
