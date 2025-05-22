import 'piece.dart';

class Player {
  final String name;
  final PieceColor color;
  final bool isHuman;
  int timeRemaining; // in seconds

  Player({
    required this.name,
    required this.color,
    this.isHuman = true,
    this.timeRemaining = 600, // Default 10 minutes
  });
}