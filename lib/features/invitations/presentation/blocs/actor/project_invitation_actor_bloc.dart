import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';

@injectable
class ProjectInvitationActorBloc
    extends Bloc<InvitationActorEvent, InvitationActorState> {
  final SendInvitationUseCase _sendInvitationUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final DeclineInvitationUseCase _declineInvitationUseCase;

  ProjectInvitationActorBloc({
    required SendInvitationUseCase sendInvitationUseCase,
    required AcceptInvitationUseCase acceptInvitationUseCase,
    required DeclineInvitationUseCase declineInvitationUseCase,
  }) : _sendInvitationUseCase = sendInvitationUseCase,
       _acceptInvitationUseCase = acceptInvitationUseCase,
       _declineInvitationUseCase = declineInvitationUseCase,
       super(InvitationActorInitial()) {
    on<SendInvitation>(_onSendInvitation);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
    on<ResetInvitationActorState>(_onResetState);
  }

  Future<void> _onSendInvitation(
    SendInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(InvitationActorLoading());

    try {
      // Use case will get current user ID internally
      final result = await _sendInvitationUseCase(event.params);

      result.fold(
        (failure) => emit(InvitationActorError(failure.message)),
        (invitation) => emit(
          InvitationActorSuccess(message: 'Invitation sent successfully'),
        ),
      );
    } catch (e) {
      emit(InvitationActorError(e.toString()));
    }
  }

  Future<void> _onAcceptInvitation(
    AcceptInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(InvitationActorLoading());

    try {
      // TODO: Implement proper invitation acceptance
      await Future.delayed(const Duration(seconds: 1));
      emit(InvitationActorSuccess(message: 'Invitation accepted successfully'));
    } catch (e) {
      emit(InvitationActorError(e.toString()));
    }
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(InvitationActorLoading());

    try {
      // TODO: Implement proper invitation decline
      await Future.delayed(const Duration(seconds: 1));
      emit(InvitationActorSuccess(message: 'Invitation declined successfully'));
    } catch (e) {
      emit(InvitationActorError(e.toString()));
    }
  }

  void _onResetState(
    ResetInvitationActorState event,
    Emitter<InvitationActorState> emit,
  ) {
    emit(InvitationActorInitial());
  }
}
