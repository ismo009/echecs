import '../models/board.dart';
import '../models/piece.dart';
import '../models/move.dart';
import '../models/position.dart';

class MoveValidator {
  // Check if a move is valid according to chess rules
  bool isValidMove(
    ChessBoard board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
    PieceColor currentTurn
  ) {
    final piece = board.getPieceAt(fromRow, fromCol);
    
    // Check if the piece exists and belongs to the current player
    if (piece == null || piece.color != currentTurn) {
      return false;
    }
    
    // Validate movement based on piece type and chess rules
    return GameRules.canPieceMoveTo(board, fromRow, fromCol, toRow, toCol);
  }
  
  // Check if a king is in check
  bool isKingInCheck(ChessBoard board, PieceColor kingColor) {
    return GameRules.isKingInCheck(board, kingColor);
  }
  
  // Check for en passant specifically
  bool isEnPassantMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol, Move? lastMove) {
    final piece = board.getPieceAt(fromRow, fromCol);
    if (piece == null || piece.type != PieceType.pawn) return false;
    
    // En passant can only happen if last move was a pawn moving two squares
    if (lastMove == null || lastMove.piece?.type != PieceType.pawn) return false;
    
    // Check if the last move was a two-square pawn move
    if ((lastMove.from.row - lastMove.to.row).abs() != 2) return false;
    
    // Check if our pawn is on the same rank as the opponent's pawn
    if (fromRow != lastMove.to.row) return false;
    
    // Check if our pawn is adjacent to the opponent's pawn
    if ((fromCol - lastMove.to.col).abs() != 1) return false;
    
    // Check if our pawn is moving diagonally behind the opponent's pawn
    final direction = piece.color == PieceColor.white ? -1 : 1;
    return toRow == fromRow + direction && toCol == lastMove.to.col;
  }
  
  // Get all valid moves for a piece
  List<List<int>> getValidMoves(
    ChessBoard board,
    int row,
    int col,
    PieceColor currentTurn,
    Move? lastMove
  ) {
    final piece = board.getPieceAt(row, col);
    final validMoves = <List<int>>[];

    if (piece == null || piece.color != currentTurn) {
      return validMoves;
    }

    // Logic for pawns
    if (piece.type == PieceType.pawn) {
      final direction = piece.color == PieceColor.white ? -1 : 1;
      final startRow = piece.color == PieceColor.white ? 6 : 1;

      // Forward move (one square)
      if (row + direction >= 0 && row + direction < 8) {
        if (board.getPieceAt(row + direction, col) == null) {
          validMoves.add([row + direction, col]);
          
          // Double forward move from starting position
          if (row == startRow && board.getPieceAt(row + 2 * direction, col) == null) {
            validMoves.add([row + 2 * direction, col]);
          }
        }
      }

      // Diagonal captures
      for (final colOffset in [-1, 1]) {
        if (col + colOffset >= 0 && col + colOffset < 8 && row + direction >= 0 && row + direction < 8) {
          final targetPiece = board.getPieceAt(row + direction, col + colOffset);
          if (targetPiece != null && targetPiece.color != piece.color) {
            validMoves.add([row + direction, col + colOffset]);
          }
        }
      }
      
      // En passant
      if (lastMove != null && lastMove.piece?.type == PieceType.pawn) {
        if ((lastMove.from.row - lastMove.to.row).abs() == 2) { // Pawn moved 2 squares
          if (row == lastMove.to.row && (col - lastMove.to.col).abs() == 1) { // Same rank, adjacent file
            validMoves.add([row + direction, lastMove.to.col]);
          }
        }
      }
    }
    
    // Add logic for other piece types
    // ...

    return validMoves;
  }

  bool isCheckmate(ChessBoard board, PieceColor color) {
    // First, check if the king is in check
    if (!isKingInCheck(board, color)) {
      return false;
    }
    
    // Then check if any move can get the king out of check
    // Implementation would check all possible moves for all pieces of this color
    return false; // Placeholder - needs real implementation
  }

  bool isStalemate(ChessBoard board, PieceColor color) {
    // Check if the player is not in check but has no legal moves
    // Implementation would check all possible moves for all pieces of this color
    return false; // Placeholder - needs real implementation
  }
}

// Helper class for game rules
class GameRules {
  static bool canPieceMoveTo(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board.getPieceAt(fromRow, fromCol);
    if (piece == null) return false;
    
    // Basic validation - can't move to a square with your own piece
    final targetPiece = board.getPieceAt(toRow, toCol);
    if (targetPiece != null && targetPiece.color == piece.color) {
      return false;
    }
    
    // Each piece type has its own movement rules
    switch (piece.type) {
      case PieceType.pawn:
        return isValidPawnMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.rook:
        return isValidRookMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.knight:
        return isValidKnightMove(fromRow, fromCol, toRow, toCol);
      case PieceType.bishop:
        return isValidBishopMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.queen:
        return isValidQueenMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.king:
        return isValidKingMove(fromRow, fromCol, toRow, toCol);
    }
  }
  
  static bool isValidPawnMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board.getPieceAt(fromRow, fromCol);
    if (piece == null || piece.type != PieceType.pawn) return false;
    
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;
    
    // Forward move
    if (toCol == fromCol) {
      // One square forward
      if (toRow == fromRow + direction && board.getPieceAt(toRow, toCol) == null) {
        return true;
      }
      
      // Two squares from start
      if (fromRow == startRow && 
          toRow == fromRow + 2 * direction && 
          board.getPieceAt(fromRow + direction, fromCol) == null &&
          board.getPieceAt(toRow, toCol) == null) {
        return true;
      }
    }
    
    // Diagonal capture
    if ((toCol == fromCol - 1 || toCol == fromCol + 1) && toRow == fromRow + direction) {
      // Regular capture
      final targetPiece = board.getPieceAt(toRow, toCol);
      if (targetPiece != null && targetPiece.color != piece.color) {
        return true;
      }
      
      // En passant would be validated separately in the MoveValidator
    }
    
    return false;
  }
  
  static bool isValidRookMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    // Simple implementation - rooks move in straight lines
    if (fromRow != toRow && fromCol != toCol) return false;
    
    // Check path is clear
    if (fromRow == toRow) {
      // Horizontal move
      final step = fromCol < toCol ? 1 : -1;
      for (int col = fromCol + step; col != toCol; col += step) {
        if (board.getPieceAt(fromRow, col) != null) return false;
      }
    } else {
      // Vertical move
      final step = fromRow < toRow ? 1 : -1;
      for (int row = fromRow + step; row != toRow; row += step) {
        if (board.getPieceAt(row, fromCol) != null) return false;
      }
    }
    
    return true;
  }
  
  static bool isValidKnightMove(int fromRow, int fromCol, int toRow, int toCol) {
    // Knights move in an L-shape
    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();
    return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
  }
  
  static bool isValidBishopMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    // Bishops move diagonally
    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();
    if (rowDiff != colDiff) return false;
    
    // Check path is clear
    final rowStep = fromRow < toRow ? 1 : -1;
    final colStep = fromCol < toCol ? 1 : -1;
    
    int row = fromRow + rowStep;
    int col = fromCol + colStep;
    
    while (row != toRow && col != toCol) {
      if (board.getPieceAt(row, col) != null) return false;
      row += rowStep;
      col += colStep;
    }
    
    return true;
  }
  
  static bool isValidQueenMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    // Queen combines rook and bishop movements
    return isValidRookMove(board, fromRow, fromCol, toRow, toCol) || 
           isValidBishopMove(board, fromRow, fromCol, toRow, toCol);
  }
  
  static bool isValidKingMove(int fromRow, int fromCol, int toRow, int toCol) {
    // Kings move one square in any direction
    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();
    return rowDiff <= 1 && colDiff <= 1;
  }
  
  static bool isKingInCheck(ChessBoard board, PieceColor kingColor) {
    // Find the king
    int kingRow = -1;
    int kingCol = -1;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPieceAt(row, col);
        if (piece != null && piece.type == PieceType.king && piece.color == kingColor) {
          kingRow = row;
          kingCol = col;
          break;
        }
      }
      if (kingRow != -1) break;
    }
    
    if (kingRow == -1) return false; // No king found (shouldn't happen in a normal game)
    
    // Check if any opponent piece can capture the king
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPieceAt(row, col);
        if (piece != null && piece.color != kingColor) {
          if (canPieceMoveTo(board, row, col, kingRow, kingCol)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
}