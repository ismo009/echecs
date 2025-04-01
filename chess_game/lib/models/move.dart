import 'position.dart';
import 'piece.dart';

class Move {
  final Position from;
  final Position to;
  final ChessPiece? piece;
  final ChessPiece? capturedPiece;
  final bool isEnPassant;
  final bool isCastling;
  final bool isPromotion;
  final PieceType? promotionPiece;

  Move({
    required this.from,
    required this.to,
    this.piece,
    this.capturedPiece,
    this.isEnPassant = false,
    this.isCastling = false,
    this.isPromotion = false,
    this.promotionPiece,
  });

  String toAlgebraicNotation() {
    if (piece == null) return ''; // Can't generate notation without a piece
    
    // Handle castling first
    if (isCastling) {
      // King-side castling
      if (from.col < to.col) {
        return 'O-O';
      } else {
        // Queen-side castling
        return 'O-O-O';
      }
    }
    
    String notation = '';
    
    // Add piece symbol unless it's a pawn
    if (piece?.type != PieceType.pawn) {
      notation += _getPieceSymbol(piece!.type);
    }
    
    // For pawn captures, add the file from which the pawn moved
    if (piece?.type == PieceType.pawn && (capturedPiece != null || isEnPassant)) {
      notation += _getFile(from.col);
    }
    
    // Add 'x' if there was a capture
    if (capturedPiece != null || isEnPassant) {
      notation += 'x';
    }
    
    // Add destination square
    notation += _getFile(to.col) + _getRank(to.row);
    
    // Add promotion piece if applicable
    if (isPromotion && promotionPiece != null) {
      notation += '=' + _getPieceSymbol(promotionPiece!);
    }
    
    return notation;
  }

  // Helper method to get the standard algebraic file (a-h)
  String _getFile(int col) {
    return String.fromCharCode('a'.codeUnitAt(0) + col);
  }

  // Helper method to get the standard algebraic rank (1-8)
  String _getRank(int row) {
    return (8 - row).toString();
  }

  // Helper method to get the symbol for each piece type
  String _getPieceSymbol(PieceType type) {
    switch (type) {
      case PieceType.king:
        return 'K';
      case PieceType.queen:
        return 'Q';
      case PieceType.rook:
        return 'R';
      case PieceType.bishop:
        return 'B';
      case PieceType.knight:
        return 'N';  // Note: Knight uses 'N'
      case PieceType.pawn:
        return '';   // Pawns have no symbol in algebraic notation
    }
  }

  @override
  String toString() {
    // Simple toString for debugging
    return 'Move: ${from.row},${from.col} -> ${to.row},${to.col}';
  }
}