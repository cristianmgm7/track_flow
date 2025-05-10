import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingChecked && state.hasCompletedOnboarding) {
          context.go('/auth');
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final List<PageViewModel> pages = [
            PageViewModel(
              title: "Welcome to TrackFlow",
              body:
                  "The ultimate platform for artists, producers, and songwriters to collaborate on music projects.",
              image: const Icon(
                Icons.music_note,
                size: 120,
                color: Colors.blue,
              ),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              title: "Collaborate Seamlessly",
              body:
                  "Work together with your team in real-time, share files, and track project progress.",
              image: const Icon(Icons.group, size: 120, color: Colors.blue),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
            PageViewModel(
              title: "Stay Organized",
              body:
                  "Keep all your projects, files, and communications in one place.",
              image: const Icon(Icons.folder, size: 120, color: Colors.blue),
              decoration: const PageDecoration(
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                bodyTextStyle: TextStyle(fontSize: 18),
              ),
            ),
          ];

          return IntroductionScreen(
            pages: pages,
            onDone: () {
              context.read<OnboardingBloc>().add(OnboardingMarkCompleted());
            },
            showSkipButton: true,
            skip: const Text("Skip"),
            onSkip: () {
              context.read<OnboardingBloc>().add(OnboardingMarkCompleted());
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
