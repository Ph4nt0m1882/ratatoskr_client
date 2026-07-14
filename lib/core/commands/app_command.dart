sealed class AppCommand {}

// Command for change the actual theme
class ChangeThemeCommand extends AppCommand {
  final String themeId; // e.g. 'light', 'dark', 'hc', 'ratatoskr'
  ChangeThemeCommand(this.themeId);
}
