enum PieceType { king, queen, rook, bishop, knight, pawn }
enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  @override
  String toString() => '${color.name} ${type.name}';

  // Get the asset path for the piece image
  String get imagePath => 'assets/images/pieces/${color.name}_${type.name}.png';

  // Create a copy of the piece
  ChessPiece copy() => ChessPiece(
        type: type,
        color: color,
        hasMoved: hasMoved,
      );
}