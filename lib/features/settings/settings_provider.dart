import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final String provider;
  final String model;

  SettingsState({required this.provider, required this.model});
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // Default model (using an older/stable model to ensure it doesn't hit rate limits)
    return SettingsState(provider: "google", model: "gemini-2.0-flash");
  }

  void changeModel(String newModel) {
    state = SettingsState(provider: state.provider, model: newModel);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
