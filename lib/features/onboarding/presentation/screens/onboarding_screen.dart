import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/utils/app_logger.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'OnboardingScreen: initState called',
      tag: 'ONBOARDING_SCREEN',
    );

    // Check onboarding status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboardingBloc = context.read<OnboardingBloc>();
      AppLogger.info(
        'OnboardingScreen: Checking onboarding status, current state: ${onboardingBloc.state.runtimeType}',
        tag: 'ONBOARDING_SCREEN',
      );

      if (onboardingBloc.state is OnboardingInitial) {
        AppLogger.info(
          'OnboardingScreen: Triggering CheckOnboardingStatus',
          tag: 'ONBOARDING_SCREEN',
        );
        onboardingBloc.add(CheckOnboardingStatus());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        AppLogger.info(
          'OnboardingScreen: Received state: ${state.runtimeType}',
          tag: 'ONBOARDING_SCREEN',
        );

        if (state is OnboardingCompleted) {
          AppLogger.info(
            'OnboardingScreen: Onboarding completed, triggering AppFlowBloc.checkAppFlow()',
            tag: 'ONBOARDING_SCREEN',
          );
          // Notify AppFlowBloc that onboarding is completed
          // This will trigger a re-evaluation of the app flow
          context.read<AppFlowBloc>().add(CheckAppFlow());
        } else if (state is OnboardingError) {
          AppLogger.error(
            'OnboardingScreen: Onboarding error: ${state.message}',
            tag: 'ONBOARDING_SCREEN',
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          AppLogger.info(
            'OnboardingScreen: Building with state: ${state.runtimeType}',
            tag: 'ONBOARDING_SCREEN',
          );

          if (state is OnboardingLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is OnboardingError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        AppLogger.info(
                          'OnboardingScreen: Retrying onboarding check',
                          tag: 'ONBOARDING_SCREEN',
                        );
                        context.read<OnboardingBloc>().add(
                          CheckOnboardingStatus(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Default onboarding content
          final pages = [
            PageViewModel(
              title: "Welcome to TrackFlow",
              body: "Your collaborative audio workspace",
              image: const Icon(Icons.music_note, size: 100),
            ),
            PageViewModel(
              title: "Collaborate",
              body: "Work together with your team on audio projects",
              image: const Icon(Icons.group, size: 100),
            ),
            PageViewModel(
              title: "Organize",
              body: "Keep your audio files organized and accessible",
              image: const Icon(Icons.folder, size: 100),
            ),
          ];

          return IntroductionScreen(
            pages: pages,
            onDone: () {
              AppLogger.info(
                'OnboardingScreen: "Get Started" button pressed, triggering MarkOnboardingCompleted',
                tag: 'ONBOARDING_SCREEN',
              );
              context.read<OnboardingBloc>().add(MarkOnboardingCompleted());
            },
            showSkipButton: true,
            skip: const Text("Skip"),
            onSkip: () {
              AppLogger.info(
                'OnboardingScreen: "Skip" button pressed, triggering MarkOnboardingCompleted',
                tag: 'ONBOARDING_SCREEN',
              );
              context.read<OnboardingBloc>().add(MarkOnboardingCompleted());
            },
            next: const Icon(Icons.arrow_forward),
            done: const Text(
              "Get Started",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            dotsDecorator: const DotsDecorator(
              size: Size(10.0, 10.0),
              color: Colors.grey,
              activeSize: Size(22.0, 10.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
            skipOrBackFlex: 0,
            nextFlex: 0,
            showBackButton: false,
            freeze: false,
            animationDuration: 350,
          );
        },
      ),
    );
  }
}
