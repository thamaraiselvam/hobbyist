import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/rating_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<InAppReview>(),
])
import 'rating_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RatingService service;
  late MockInAppReview mockInAppReview;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockInAppReview = MockInAppReview();
    service = RatingService(inAppReview: mockInAppReview);
  });

  group('RatingService Tests', () {
    test('incrementCompletionCount updates prefs', () async {
      await service.incrementCompletionCount();
      expect(await service.getCompletionCount(), 1);

      await service.incrementCompletionCount();
      expect(await service.getCompletionCount(), 2);
    });

    test('checkAndShowRatingPrompt shows on first completion', () async {
      await service.incrementCompletionCount(); // count = 1

      when(mockInAppReview.isAvailable()).thenAnswer((_) async => true);

      await service.checkAndShowRatingPrompt();

      verify(mockInAppReview.isAvailable()).called(1);
      verify(mockInAppReview.requestReview()).called(1);
    });

    test('checkAndShowRatingPrompt skips if already rated', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_rated_app', true);
      await service.incrementCompletionCount(); // count = 1

      await service.checkAndShowRatingPrompt();

      verifyNever(mockInAppReview.isAvailable());
    });

    test('checkAndShowRatingPrompt shows on 10th completion if skipped before',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_rating_prompt_shown', true);
      for (int i = 0; i < 10; i++) {
        await service.incrementCompletionCount();
      }

      when(mockInAppReview.isAvailable()).thenAnswer((_) async => true);

      await service.checkAndShowRatingPrompt();

      verify(mockInAppReview.requestReview()).called(1);
    });

    test('checkAndShowRatingPrompt fallback to store listing', () async {
      await service.incrementCompletionCount(); // count = 1

      when(mockInAppReview.isAvailable()).thenAnswer((_) async => false);

      await service.checkAndShowRatingPrompt();

      verify(mockInAppReview.openStoreListing()).called(1);
    });

    test('openStoreListing calls inAppReview', () async {
      await service.openStoreListing();
      verify(mockInAppReview.openStoreListing(
              appStoreId: anyNamed('appStoreId')))
          .called(1);
    });

    test('resetRatingState clears prefs', () async {
      await service.incrementCompletionCount();
      await service.resetRatingState();
      expect(await service.getCompletionCount(), 0);
    });

    test('Error handling when openStoreListing fails', () async {
      await service.incrementCompletionCount(); // count = 1
      when(mockInAppReview.isAvailable()).thenAnswer((_) async => false);
      when(mockInAppReview.openStoreListing())
          .thenThrow(Exception('store error'));

      // Should not throw
      await expectLater(service.checkAndShowRatingPrompt(), completes);
    });
  });
}
