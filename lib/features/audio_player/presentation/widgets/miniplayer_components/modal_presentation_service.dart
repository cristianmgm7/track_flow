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
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            height: MediaQuery.of(modalContext).size.height * 0.9,
            decoration: BoxDecoration(
              color: Theme.of(modalContext).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: BlocProvider.of<AudioPlayerBloc>(context),
                        ),
                        BlocProvider.value(
                          value: BlocProvider.of<AudioContextBloc>(context),
                        ),
                      ],
                      child: const PureAudioPlayer(),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
