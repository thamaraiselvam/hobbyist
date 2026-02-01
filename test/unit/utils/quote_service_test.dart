import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/quote_service.dart';

void main() {
  group('QuoteService Tests', () {
    late QuoteService quoteService;

    setUp(() {
      quoteService = QuoteService();
    });

    test('should create QuoteService instance', () {
      expect(quoteService, isNotNull);
    });

    test('should return a random quote', () {
      final quote = quoteService.getRandomQuote();
      expect(quote, isNotEmpty);
    });

    test('should return non-null quote', () {
      final quote = quoteService.getRandomQuote();
      expect(quote, isNotNull);
    });

    test('should return quotes of reasonable length', () {
      for (int i = 0; i < 20; i++) {
        final quote = quoteService.getRandomQuote();
        expect(quote.length, greaterThan(10));
        expect(quote.length, lessThan(200));
      }
    });

    test('should return different quotes over multiple calls', () {
      final quotes = <String>{};
      for (int i = 0; i < 50; i++) {
        quotes.add(quoteService.getRandomQuote());
      }
      // With 100+ quotes, getting 50 random ones should yield multiple unique ones
      expect(quotes.length, greaterThan(5));
    });

    test('quotes should not start with whitespace', () {
      for (int i = 0; i < 30; i++) {
        final quote = quoteService.getRandomQuote();
        expect(quote.trimLeft(), quote);
      }
    });

    test('quotes should not end with whitespace', () {
      for (int i = 0; i < 30; i++) {
        final quote = quoteService.getRandomQuote();
        expect(quote.trimRight(), quote);
      }
    });

    test('quotes should be motivational (contain positive words)', () {
      final positiveWords = [
        'success',
        'dream',
        'goal',
        'progress',
        'believe',
        'achieve',
        'start',
        'now',
        'great',
        'best',
        'work',
        'can',
        'do',
        'try',
        'win',
        'habit'
      ];

      bool foundPositive = false;
      for (int i = 0; i < 100; i++) {
        final quote = quoteService.getRandomQuote().toLowerCase();
        if (positiveWords.any((word) => quote.contains(word))) {
          foundPositive = true;
          break;
        }
      }
      expect(foundPositive, true);
    });
  });
}
