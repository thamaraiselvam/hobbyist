// Integration test entry point for CI.
//
// flutter build apk --debug --target=integration_test/app_test.dart
// flutter test integration_test/app_test.dart   (requires device/emulator)
import 'package:integration_test/integration_test.dart';

import 'analytics_streak_test.dart' as analytics_streak;
import 'audio_quotes_notifications_test.dart' as audio_quotes;
import 'complete_app_flow_test.dart' as complete_app_flow;
import 'day_selector_scroll_test.dart' as day_selector;
import 'edge_cases_test.dart' as edge_cases;
import 'hobby_creation_notification_test.dart' as hobby_creation;
import 'settings_navigation_ui_test.dart' as settings_navigation;
import 'validation_database_test.dart' as validation_database;
import 'widget_interactions_test.dart' as widget_interactions;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  analytics_streak.main();
  audio_quotes.main();
  complete_app_flow.main();
  day_selector.main();
  edge_cases.main();
  hobby_creation.main();
  settings_navigation.main();
  validation_database.main();
  widget_interactions.main();
}
