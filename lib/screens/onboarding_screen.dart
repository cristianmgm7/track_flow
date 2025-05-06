import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PageViewModel> pages = [
      PageViewModel(
        title: "Welcome to TrackFlow",
        body:
            "The ultimate platform for artists, producers, and songwriters to collaborate on music projects.",
        image: const Icon(Icons.music_note, size: 120, color: Colors.blue),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(fontSize: 18),
        ),
      ),
      PageViewModel(
        title: "Collaborate Seamlessly",
        body:
            "Work together with your team in real-time, share files, and track project progress.",
        image: const Icon(Icons.group, size: 120, color: Colors.blue),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(fontSize: 18),
        ),
      ),
      PageViewModel(
        title: "Stay Organized",
        body: "Keep all your projects, files, and communications in one place.",
        image: const Icon(Icons.folder, size: 120, color: Colors.blue),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(fontSize: 18),
        ),
      ),
    ];

    return IntroductionScreen(
      pages: pages,
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Skip"),
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
    );
  }
}
