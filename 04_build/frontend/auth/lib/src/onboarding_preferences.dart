import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingPreferences {
  Future<bool> isComplete();

  Future<void> markComplete();

  Future<void> clear();
}

final class SharedPrefsOnboardingPreferences implements OnboardingPreferences {
  const SharedPrefsOnboardingPreferences({SharedPreferences? preferences})
    : this._(preferences);

  const SharedPrefsOnboardingPreferences._(this._preferences);

  static const completeKey = 'onboarding_complete';

  final SharedPreferences? _preferences;

  @override
  Future<bool> isComplete() async {
    final preferences = await _resolve();
    return preferences.getBool(completeKey) ?? false;
  }

  @override
  Future<void> markComplete() async {
    final preferences = await _resolve();
    await preferences.setBool(completeKey, true);
  }

  @override
  Future<void> clear() async {
    final preferences = await _resolve();
    await preferences.remove(completeKey);
  }

  Future<SharedPreferences> _resolve() async {
    return _preferences ?? SharedPreferences.getInstance();
  }
}
