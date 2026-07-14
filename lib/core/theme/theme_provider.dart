import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../commands/app_command.dart';
import '../commands/command_bus.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Get the central pipe
    final commandBus = ref.watch(commandBusProvider);

    // Listen to everything that plays on it
    commandBus.stream.listen((command) {
      // If it's a command to change the theme
      if (command is ChangeThemeCommand) {
        if (command.themeId == 'dark') {
          state = ThemeMode.dark;
        } else if (command.themeId == 'light') {
          state = ThemeMode.light;
        } else {
          state = ThemeMode.system;
        }
      }
    });

    return ThemeMode.system; // By default, follow the system theme
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
