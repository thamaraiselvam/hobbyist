/// Centralized Maestro test IDs for all interactive widgets.
///
/// Usage in Flutter:
///   key: const Key(TestKeys.landingContinueButton)
///   key: Key(TestKeys.taskCheckbox(hobby.id))
///
/// Usage in Maestro YAML:
///   tapOn:
///     id: "continue_offline_button"
///
/// ⚠️ SECURITY RULES (enforced by code review):
///   - Keys may only use STATIC strings or hobby.id (a timestamp string).
///   - NEVER use hobby.name, hobby.notes, or any user-generated content as a key.
///   - hobby.id is a timestamp string — it identifies a record without leaking content.
class TestKeys {
  TestKeys._();

  // ─── LANDING SCREEN ──────────────────────────────────────────────────────
  static const String landingContinueButton = 'continue_offline_button';

  // ─── NAME INPUT SCREEN ───────────────────────────────────────────────────
  static const String nameInputField = 'name_input_field';
  static const String nameSubmitButton = 'start_journey_button';

  // ─── ADD HOBBY SCREEN ────────────────────────────────────────────────────
  static const String addHobbyNameInput = 'hobby_name_input';
  static const String addHobbyNotifyToggle = 'notify_toggle';
  static const String addHobbyOneTimeToggle = 'one_time_toggle';
  static const String addHobbyReminderPicker = 'reminder_time_picker';
  static const String addHobbySubmitButton = 'create_hobby_button';

  /// mode: 'daily' | 'weekly' | 'monthly' → e.g. 'daily_frequency_button'
  static String addHobbyFrequencyButton(String mode) =>
      '${mode}_frequency_button';

  /// index 0–9, matching _colorPalette order → e.g. 'color_palette_button_3'
  static String addHobbyColorButton(int index) => 'color_palette_button_$index';

  /// index 0–6 (Mon=0 … Sun=6) → e.g. 'weekday_button_2'
  static String addHobbyWeekdayButton(int index) => 'weekday_button_$index';

  // ─── BOTTOM NAVIGATION (shared across DailyTasks / Analytics / Settings) ─
  static const String navHome = 'bottom_nav_home';
  static const String navTasksList = 'bottom_nav_tasks_list';
  static const String navAnalytics = 'bottom_nav_analytics';
  static const String navSettings = 'bottom_nav_settings';

  /// index: 0=home, 1=tasks list, 2=analytics, 3=settings
  static String navItem(int index) => const [
        navHome,
        navTasksList,
        navAnalytics,
        navSettings,
      ][index];

  /// The centre (+) create button in the bottom nav bar.
  static const String addHobbyFab = 'add_hobby_fab';

  // ─── ONE-TIME TASKS SCREEN ───────────────────────────────────────────────
  /// ⚠️ taskId = task.id (UUID string), NOT task.title
  static String taskItem(String taskId) => 'task_item_$taskId';
  static String taskItemCheckbox(String taskId) => 'task_item_checkbox_$taskId';
  static String taskItemMenu(String taskId) => 'task_item_menu_$taskId';

  // ─── DAILY TASKS SCREEN ──────────────────────────────────────────────────
  static const String streakBadge = 'streak_badge';

  /// dateStr: 'yyyy-MM-dd' → e.g. 'day_pill_2026-02-19'
  static String dayPill(String dateStr) => 'day_pill_$dateStr';

  /// ⚠️ hobbyId = hobby.id (timestamp string), NOT hobby.name
  static String taskCard(String hobbyId) => 'task_card_$hobbyId';
  static String taskCheckbox(String hobbyId) => 'hobby_checkbox_$hobbyId';
  static String hobbyMenu(String hobbyId) => 'hobby_menu_$hobbyId';

  // ─── ANALYTICS SCREEN ────────────────────────────────────────────────────
  /// period: 'weekly' | 'monthly' | 'yearly' → e.g. 'period_weekly_button'
  static String analyticsPeriodButton(String period) =>
      'period_${period.toLowerCase()}_button';

  // ─── SETTINGS SCREEN ─────────────────────────────────────────────────────
  static const String settingsEditName = 'edit_name_button';
  static const String settingsPushNotifications = 'push_notifications_toggle';
  static const String settingsSoundVibration = 'completion_sound_toggle';
  static const String settingsRateApp = 'rate_app_button';
  static const String settingsSendFeedback = 'send_feedback_button';
  static const String settingsPrivacyPolicy = 'privacy_policy_button';
  static const String settingsAbout = 'app_version_info';
  static const String settingsDeveloperOptions = 'developer_options_button';
  static const String settingsLogout = 'logout_button';
  static const String settingsRefreshFlags = 'refresh_flags_button';

  // ─── FEEDBACK SCREEN ─────────────────────────────────────────────────────
  static const String feedbackInput = 'feedback_textarea';
  static const String feedbackEmailInput = 'email_input';
  static const String feedbackSubmitButton = 'submit_feedback_button';
}
