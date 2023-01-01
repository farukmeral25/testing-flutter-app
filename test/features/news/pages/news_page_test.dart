import 'package:flutter/material.dart';
import 'package:flutter_app_test/features/news/data/service/news_service.dart';
import 'package:flutter_app_test/features/news/domain/entity/article.dart';
import 'package:flutter_app_test/features/news/pages/news_page.dart';
import 'package:flutter_app_test/features/news/viewmodel/news_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test 1 content'),
    Article(title: 'Test 2', content: 'Test 2 content'),
    Article(title: 'Test 3', content: 'Test 3 content'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.fetchArticles()).thenAnswer(
      (_) async => articlesFromService,
    );
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondWait() {
    when(() => mockNewsService.fetchArticles()).thenAnswer(
      (_) async {
        await Future.delayed(const Duration(seconds: 2));
        return articlesFromService;
      },
    );
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsViewModel(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets('title is displayed', (tester) async {
    arrangeNewsServiceReturns3Articles();

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text("News"), findsOneWidget);
  });

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2SecondWait();

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump(const Duration(milliseconds: 500));

      final itemFinder = find.byKey(const ValueKey('progress-indicator'));

      expect(itemFinder, findsOneWidget);

      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();

      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
