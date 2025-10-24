import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pure_audio_player.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../../../audio_context/presentation/bloc/audio_context_bloc.dart';

abstract class IModalPresentationService {
  void showFullPlayerModal(BuildContext context);
}

class ModalPresentationService implements IModalPresentationService {
  
  @override
  void showFullPlayerModal(BuildContext context) {
    // Read blocs up-front to avoid looking up ancestors from a possibly deactivated context later
    final audioPlayerBloc = BlocProvider.of<AudioPlayerBloc>(context);
    final audioContextBloc = BlocProvider.of<AudioContextBloc>(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (modalContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: audioPlayerBloc,
            ),
            BlocProvider.value(
              value: audioContextBloc,
            ),
          ],
          child: const PureAudioPlayer(
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }
}
