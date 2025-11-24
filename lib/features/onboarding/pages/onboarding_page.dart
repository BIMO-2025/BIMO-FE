import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/onboarding_content.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/page_indicator.dart';
import '../../../core/network/router/route_names.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onSkip() {
    // Navigate to home or auth
    // TODO: 로그인 상태에 따라 라우팅
    context.go(RouteNames.login);
  }

  void _onNext() {
    if (_currentPage < OnboardingContent.contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _onSkip, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingContent.contents.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    content: OnboardingContent.contents[index],
                  );
                },
              ),
            ),
            PageIndicator(
              currentPage: _currentPage,
              pageCount: OnboardingContent.contents.length,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  child: Text(
                    _currentPage == OnboardingContent.contents.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
