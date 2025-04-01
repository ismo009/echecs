class Position {
  final int row;
  final int col;

  const Position({required this.row, required this.col});

  @override
  String toString() {
    // Convert to chess notation (e.g., e4, a8)
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = 8 - row;
    return '$file$rank';
  }
}