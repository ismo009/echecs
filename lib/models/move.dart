import 'piece.dart';

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

class Move {
  final Position from;
  final Position to;
  final ChessPiece? piece;
  final ChessPiece? capturedPiece;
  final bool isCheck;
  final bool isCheckmate;
  final bool isCastling;
  final bool isEnPassant;
  final bool isPawnPromotion;
  final PieceType? promotionPiece;

  Move({
    required this.from,
    required this.to,
    this.piece,
    this.capturedPiece,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isCastling = false,
    this.isEnPassant = false,
    this.isPawnPromotion = false,
    this.promotionPiece,
  });

  // Convert the move to algebraic notation
  String toAlgebraicNotation() {
    if (isCastling) {
      return (to.col > from.col) ? 'O-O' : 'O-O-O';
    }

    String notation = '';
    if (piece != null) {
      if (piece!.type != PieceType.pawn) {
        // Add piece letter (K, Q, R, B, N)
        switch (piece!.type) {
          case PieceType.king:
            notation += 'K';
            break;
          case PieceType.queen:
            notation += 'Q';
            break;
          case PieceType.rook:
            notation += 'R';
            break;
          case PieceType.bishop:
            notation += 'B';
            break;
          case PieceType.knight:
            notation += 'N';
            break;
          default:
            break;
        }
      }
    }

    // Add 'x' for captures
    if (capturedPiece != null) {
      if (piece?.type == PieceType.pawn) {
        notation += '${from.toString()[0]}'; // Add file for pawn captures
      }
      notation += 'x';
    }

    // Add destination square
    notation += to.toString();

    // Add promotion piece
    if (isPawnPromotion && promotionPiece != null) {
      notation += '=';
      switch (promotionPiece!) {
        case PieceType.queen:
          notation += 'Q';
          break;
        case PieceType.rook:
          notation += 'R';
          break;
        case PieceType.bishop:
          notation += 'B';
          break;
        case PieceType.knight:
          notation += 'N';
          break;
        default:
          break;
      }
    }

    // Add check and checkmate symbols
    if (isCheckmate) {
      notation += '#';
    } else if (isCheck) {
      notation += '+';
    }

    return notation;
  }
}