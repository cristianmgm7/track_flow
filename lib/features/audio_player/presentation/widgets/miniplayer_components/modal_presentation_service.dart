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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        final mediaQuery = MediaQuery.of(modalContext);
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
            child: SizedBox(
              height: mediaQuery.size.height * 0.9,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<AudioPlayerBloc>(context),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<AudioContextBloc>(context),
                  ),
                ],
                child: const PureAudioPlayer(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
