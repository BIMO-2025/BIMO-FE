import 'package:flutter/foundation.dart';

class OnboardingProvider extends ChangeNotifier {
  bool _isOnboardingCompleted = false;

  bool get isOnboardingCompleted => _isOnboardingCompleted;

  Future<void> checkOnboardingStatus() async {
    // Load from shared preferences or secure storage
    // _isOnboardingCompleted = await _storage.getOnboardingStatus();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    // Save to shared preferences or secure storage
    // await _storage.setOnboardingStatus(true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _isOnboardingCompleted = false;
    // Clear from storage
    // await _storage.setOnboardingStatus(false);
    notifyListeners();
  }
}

