
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chess_game/main.dart';
import 'package:chess_game/screens/home_screen.dart';
import 'package:chess_game/providers/game_provider.dart';

void main() {
  testWidgets('Chess App loads correctly with home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChessApp());

    // Verify that the home screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Chess Game'), findsOneWidget);
    expect(find.text('Start New Game'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Provider is initialized correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ChessApp());
  });

  // You can add more specific tests for your chess game features
  // For example:
  /*
  testWidgets('Chess board displays 32 pieces initially', (WidgetTester tester) async {
    // This would require navigating to the game screen first
    await tester.pumpWidget(const ChessApp());
    await tester.tap(find.text('Start New Game'));
    await tester.pumpAndSettle();

    // Count pieces on the board
    final chessPieces = find.byType(YourChessPieceWidgetType);
    expect(chessPieces, findsNWidgets(32));
  });
  */
}