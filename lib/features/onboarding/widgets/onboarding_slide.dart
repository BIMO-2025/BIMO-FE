import 'package:flutter/material.dart';
import '../models/onboarding_content.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingSlide({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for image
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

