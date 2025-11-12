class OnboardingContent {
  final String title;
  final String description;
  final String image;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });

  static List<OnboardingContent> contents = [
    const OnboardingContent(
      title: 'Welcome to BIMO',
      description: 'Your journey starts here',
      image: 'assets/images/onboarding1.png',
    ),
    const OnboardingContent(
      title: 'Easy to Use',
      description: 'Simple and intuitive interface',
      image: 'assets/images/onboarding2.png',
    ),
    const OnboardingContent(
      title: 'Get Started',
      description: 'Let\'s begin your experience',
      image: 'assets/images/onboarding3.png',
    ),
  ];
}

