import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pure_audio_player.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../../../core/theme/app_colors.dart';

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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey900.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: BlocProvider.of<AudioPlayerBloc>(
                                  context,
                                ),
                              ),
                              BlocProvider.value(
                                value: BlocProvider.of<AudioContextBloc>(
                                  context,
                                ),
                              ),
                            ],
                            child: const PureAudioPlayer(
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
