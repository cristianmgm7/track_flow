// import 'package:flutter/material.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<OnboardingPage> _pages = [
//     OnboardingPage(
//       title: 'Welcome to TrackFlow',
//       description:
//           'The ultimate platform for artists, producers, and songwriters to collaborate on music projects.',
//       icon: Icons.music_note,
//     ),
//     OnboardingPage(
//       title: 'Collaborate Seamlessly',
//       description:
//           'Work together with your team in real-time, share files, and track project progress.',
//       icon: Icons.group,
//     ),
//     OnboardingPage(
//       title: 'Stay Organized',
//       description:
//           'Keep all your projects, files, and communications in one place.',
//       icon: Icons.folder,
//     ),
//   ];

//   void _completeOnboarding() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasCompletedOnboarding', true);
//     if (mounted) {
//       Navigator.of(context).pushReplacementNamed('/dashboard');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: _pages.length,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentPage = index;
//                   });
//                 },
//                 itemBuilder: (context, index) {
//                   return _buildPage(_pages[index]);
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Page indicator
//                   Row(
//                     children: List.generate(
//                       _pages.length,
//                       (index) => Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               _currentPage == index
//                                   ? Theme.of(context).primaryColor
//                                   : Colors.grey.shade300,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Next/Finish button
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_currentPage == _pages.length - 1) {
//                         _completeOnboarding();
//                       } else {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                     },
//                     child: Text(
//                       _currentPage == _pages.length - 1
//                           ? 'Get Started'
//                           : 'Next',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPage(OnboardingPage page) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(page.icon, size: 100, color: Theme.of(context).primaryColor),
//           const SizedBox(height: 32),
//           Text(
//             page.title,
//             style: Theme.of(context).textTheme.headlineMedium,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             page.description,
//             style: Theme.of(context).textTheme.bodyLarge,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OnboardingPage {
//   final String title;
//   final String description;
//   final IconData icon;

//   OnboardingPage({
//     required this.title,
//     required this.description,
//     required this.icon,
//   });
// }
