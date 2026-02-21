import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/feedback_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
])
import 'feedback_service_test.mocks.dart';

void main() {
  late FeedbackService service;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    when(mockFirestore.collection(any)).thenReturn(mockCollection);

    service = FeedbackService(firestore: mockFirestore);
  });

  group('FeedbackService Tests', () {
    test('submitFeedback success', () async {
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

      final result = await service.submitFeedback(
        feedbackText: 'Great app!',
        email: 'test@example.com',
      );

      expect(result, true);
      verify(mockFirestore.collection('feedback')).called(1);
      verify(
        mockCollection.add(argThat(containsPair('feedback', 'Great app!'))),
      ).called(1);
    });

    test('submitFeedback empty text', () async {
      final result = await service.submitFeedback(feedbackText: '  ');

      expect(result, false);
      verifyNever(mockFirestore.collection(any));
    });

    test('submitFeedback too long text', () async {
      final longText = 'a' * 501;
      final result = await service.submitFeedback(feedbackText: longText);

      expect(result, false);
      verifyNever(mockFirestore.collection(any));
    });

    test('submitFeedback firestore error', () async {
      when(mockCollection.add(any)).thenThrow(
        FirebaseException(plugin: 'firestore', message: 'test error'),
      );

      final result = await service.submitFeedback(feedbackText: 'test');

      expect(result, false);
    });
  });
}
