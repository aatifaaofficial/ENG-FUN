// ignore_for_file: use_super_parameters, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/constants/app_constants.dart';

// ১. অনবোর্ডিং ডেটার জন্য লোকাল ডাটা স্ট্রাকচার (মক ডাটা মুক্ত)
class OnboardingData {
  final String title;
  final String description;
  final String icon;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // ২. প্রোডাকশন রেডি অ্যাপ কনটেন্ট
  final List<OnboardingData> _onboardingPages = const [
    OnboardingData(
      title: "সহজে ইংরেজি শিখুন",
      description:
          "দৈনন্দিন জীবনে ব্যবহৃত প্রয়োজনীয় ইংরেজি শব্দ ও বাক্য শিখুন একদম সহজ উপায়ে এবং মজার ছলে।",
      icon: "📚",
    ),
    OnboardingData(
      title: "রেগুলার প্র্যাকটিস কুইজ",
      description:
          "আপনার শেখা পড়াগুলো মনে রাখতে কুইজ এবং গেমসে অংশ নিন এবং নিজের স্কোর চেক করুন।",
      icon: "🎯",
    ),
    OnboardingData(
      title: "আপনার অগ্রগতি ট্র্যাক করুন",
      description:
          "প্রতিদিনের স্ট্রিক ধরে রাখুন এবং ডাটাবেসের মাধ্যমে আপনার নিয়মিত উন্নতির গ্রাফ দেখুন।",
      icon: "📈",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ৩. অনবোর্ডিং শেষ হলে লোকাল সেশন আপডেট বা নেভিগেশন হ্যান্ডলার
  void _completeOnboarding() {
    // এখানে চাইলে Shared Preferences এ অনবোর্ডিং ট্রু করে দিতে পারেন
    // যেমন: prefs.setBool('seen_onboarding', true);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingPages.length,
              // 🎯 এখানে 'builder:' এর জায়গায় 'itemBuilder:' হবে
              itemBuilder: (context, index) {
                final page = _onboardingPages[index];
                return OnboardingPageWidget(
                  title: page.title,
                  description: page.description,
                  icon: page.icon,
                );
              },
            ),

            // নিচের ইন্ডিকেটর এবং রিয়েল নেভিগেশন বাটন প্যানেল
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // পেজ ডট ইন্ডিকেটর ডাইনামিক অ্যানিমেশন
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF0D47A1)
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // অ্যাকশন বাটনসমূহ (AppStrings এর সাথে কানেক্টেড বা ডাইনামিক টেক্সট)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ব্যাক বাটন সচল করা
                        if (_currentPage > 0)
                          RoundedButton(
                            label: AppStrings.back, // অথবা "পেছনে"
                            onPressed: () {
                              _pageController.previousPage(
                                duration: AppConstants.mediumDuration,
                                curve: Curves.easeInOut,
                              );
                            },
                          )
                        else
                          const SizedBox(
                              width: 100), // ইউআই ব্যালেন্স ঠিক রাখার জন্য

                        // নেক্সট অথবা গেট স্টার্টেড বাটন লজিক
                        if (_currentPage < _onboardingPages.length - 1)
                          RoundedButton(
                            label: AppStrings.next, // অথবা "সামনে"
                            onPressed: () {
                              _pageController.nextPage(
                                duration: AppConstants.mediumDuration,
                                curve: Curves.easeInOut,
                              );
                            },
                          )
                        else
                          RoundedButton(
                            label: AppStrings.getStarted, // অথবা "শুরু করুন"
                            onPressed: _completeOnboarding,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String icon;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text(
              icon,
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D47A1),
                      ) ??
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                          height: 1.4,
                        ) ??
                    const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
                height: 120), // বাটন প্যানেলের স্পেসিং ওভারল্যাপ রোধ করতে
          ],
        ),
      ),
    );
  }
}
