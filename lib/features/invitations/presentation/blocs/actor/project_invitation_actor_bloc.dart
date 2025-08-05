import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart';

@injectable
class ProjectInvitationActorBloc
    extends Bloc<InvitationActorEvent, InvitationActorState> {
  final SendInvitationUseCase _sendInvitationUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final DeclineInvitationUseCase _declineInvitationUseCase;
  final CancelInvitationUseCase _cancelInvitationUseCase;
  final FindUserByEmailUseCase _findUserByEmailUseCase;

  ProjectInvitationActorBloc({
    required SendInvitationUseCase sendInvitationUseCase,
    required AcceptInvitationUseCase acceptInvitationUseCase,
    required DeclineInvitationUseCase declineInvitationUseCase,
    required CancelInvitationUseCase cancelInvitationUseCase,
    required FindUserByEmailUseCase findUserByEmailUseCase,
  }) : _sendInvitationUseCase = sendInvitationUseCase,
       _acceptInvitationUseCase = acceptInvitationUseCase,
       _declineInvitationUseCase = declineInvitationUseCase,
       _cancelInvitationUseCase = cancelInvitationUseCase,
       _findUserByEmailUseCase = findUserByEmailUseCase,
       super(InvitationActorInitial()) {
    on<SendInvitation>(_onSendInvitation);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
    on<CancelInvitation>(_onCancelInvitation);
    on<SearchUserByEmail>(_onSearchUserByEmail);
    on<ClearUserSearch>(_onClearUserSearch);
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
      final result = await _acceptInvitationUseCase(event.invitationId);

      result.fold(
        (failure) => emit(InvitationActorError(failure.message)),
        (invitation) => emit(
          AcceptInvitationSuccess(
            message: 'Invitation accepted successfully',
            invitation: invitation,
          ),
        ),
      );
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
      final result = await _declineInvitationUseCase(event.invitationId);

      result.fold(
        (failure) => emit(InvitationActorError(failure.message)),
        (invitation) => emit(
          DeclineInvitationSuccess(
            message: 'Invitation declined successfully',
            invitation: invitation,
          ),
        ),
      );
    } catch (e) {
      emit(InvitationActorError(e.toString()));
    }
  }

  Future<void> _onCancelInvitation(
    CancelInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(InvitationActorLoading());

    try {
      final result = await _cancelInvitationUseCase(event.invitationId);

      result.fold(
        (failure) => emit(InvitationActorError(failure.message)),
        (_) => emit(
          CancelInvitationSuccess(message: 'Invitation cancelled successfully'),
        ),
      );
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

  Future<void> _onSearchUserByEmail(
    SearchUserByEmail event,
    Emitter<InvitationActorState> emit,
  ) async {
    final email = event.email.trim();

    // Clear search if email is empty
    if (email.isEmpty) {
      emit(InvitationActorInitial());
      return;
    }

    emit(UserSearchLoading());

    try {
      final result = await _findUserByEmailUseCase(email);

      result.fold(
        (failure) => emit(UserSearchError(failure.message)),
        (user) => emit(UserSearchSuccess(user)),
      );
    } catch (e) {
      emit(UserSearchError('Unexpected error: $e'));
    }
  }

  void _onClearUserSearch(
    ClearUserSearch event,
    Emitter<InvitationActorState> emit,
  ) {
    emit(InvitationActorInitial());
  }
}
