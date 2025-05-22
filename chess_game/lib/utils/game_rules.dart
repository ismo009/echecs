import '../models/board.dart';
import '../models/move.dart';
import '../models/piece.dart';

class GameRules {
  // Checks if a king is in check
  static bool isKingInCheck(ChessBoard board, PieceColor kingColor) {
    // Find king position
    int? kingRow;
    int? kingCol;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPieceAt(row, col);
        if (piece != null && 
            piece.type == PieceType.king && 
            piece.color == kingColor) {
          kingRow = row;
          kingCol = col;
          break;
        }
      }
      if (kingRow != null) break;
    }
    
    if (kingRow == null || kingCol == null) return false;
    
    // Check if any opponent piece can attack the king
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPieceAt(row, col);
        if (piece != null && piece.color != kingColor) {
          // Check if this piece can attack the king
          if (canPieceMoveTo(board, row, col, kingRow, kingCol, checkForCheck: false)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  // Checks if a move would put the player's own king in check
  static bool wouldMoveExposeKing(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    // Create a copy of the board to simulate the move
    final tempBoard = board.copy();
    final movingPiece = tempBoard.getPieceAt(fromRow, fromCol);
    
    if (movingPiece == null) return false;
    
    // Simulate the move
    tempBoard.movePiece(fromRow, fromCol, toRow, toCol);
    
    // Check if the move would expose the king to check
    return isKingInCheck(tempBoard, movingPiece.color);
  }
  
  // Basic validation of piece movement
  static bool canPieceMoveTo(
    ChessBoard board, 
    int fromRow, 
    int fromCol, 
    int toRow, 
    int toCol, 
    {bool checkForCheck = true}
  ) {
    final piece = board.getPieceAt(fromRow, fromCol);
    final targetPiece = board.getPieceAt(toRow, toCol);
    
    if (piece == null) return false;
    
    // Cannot capture own piece
    if (targetPiece != null && targetPiece.color == piece.color) return false;
    
    // Check if the move would expose king to check
    if (checkForCheck && wouldMoveExposeKing(board, fromRow, fromCol, toRow, toCol)) {
      return false;
    }
    
    // Movement logic for each piece type
    switch (piece.type) {
      case PieceType.pawn:
        return validatePawnMove(board, piece.color, fromRow, fromCol, toRow, toCol);
      case PieceType.knight:
        return validateKnightMove(fromRow, fromCol, toRow, toCol);
      case PieceType.bishop:
        return validateBishopMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.rook:
        return validateRookMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.queen:
        return validateQueenMove(board, fromRow, fromCol, toRow, toCol);
      case PieceType.king:
        return validateKingMove(board, piece.hasMoved, fromRow, fromCol, toRow, toCol);
    }
  }
  
  // Validates pawn movement
  static bool validatePawnMove(ChessBoard board, PieceColor color, int fromRow, int fromCol, int toRow, int toCol) {
    // Direction of movement (white moves up, black moves down)
    final direction = color == PieceColor.white ? -1 : 1;
    final startingRow = color == PieceColor.white ? 6 : 1;
    
    // Normal move forward
    if (fromCol == toCol && toRow == fromRow + direction && board.getPieceAt(toRow, toCol) == null) {
      return true;
    }
    
    // Double move from starting position
    if (fromCol == toCol && fromRow == startingRow && toRow == fromRow + 2 * direction &&
        board.getPieceAt(fromRow + direction, fromCol) == null && 
        board.getPieceAt(toRow, toCol) == null) {
      return true;
    }
    
    // Capture diagonally
    if ((toCol == fromCol + 1 || toCol == fromCol - 1) && 
        toRow == fromRow + direction && 
        board.getPieceAt(toRow, toCol) != null &&
        board.getPieceAt(toRow, toCol)?.color != color) {
      return true;
    }
    
    // TODO: Implement en passant and promotion
    
    return false;
  }
  
  // Validates knight movement
  static bool validateKnightMove(int fromRow, int fromCol, int toRow, int toCol) {
    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();
    
    // Knights move in an L-shape: 2 squares in one direction and 1 square perpendicular
    return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
  }
  
  // Validates bishop movement
  static bool validateBishopMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();
    
    // Bishops move diagonally
    if (rowDiff != colDiff) return false;
    
    // Check if path is clear
    final rowDirection = toRow > fromRow ? 1 : -1;
    final colDirection = toCol > fromCol ? 1 : -1;
    
    for (int i = 1; i < rowDiff; i++) {
      if (board.getPieceAt(fromRow + i * rowDirection, fromCol + i * colDirection) != null) {
        return false;
      }
    }
    
    return true;
  }
  
  // Validates rook movement
  static bool validateRookMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    // Rooks move horizontally or vertically
    if (fromRow != toRow && fromCol != toCol) return false;
    
    // Check if path is clear
    if (fromRow == toRow) {
      // Horizontal move
      final direction = toCol > fromCol ? 1 : -1;
      for (int col = fromCol + direction; col != toCol; col += direction) {
        if (board.getPieceAt(fromRow, col) != null) {
          return false;
        }
      }
    } else {
      // Vertical move
      final direction = toRow > fromRow ? 1 : -1;
      for (int row = fromRow + direction; row != toRow; row += direction) {
        if (board.getPieceAt(row, fromCol) != null) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  // Validates queen movement
  static bool validateQueenMove(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    // Queen combines rook and bishop movement
    return validateRookMove(board, fromRow, fromCol, toRow, toCol) ||
           validateBishopMove(board, fromRow, fromCol, toRow, toCol);
  }
  
  // Validates king movement
  static bool validateKingMove(
    ChessBoard board,
    bool kingHasMoved,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
) {
  final rowDiff = (fromRow - toRow).abs();
  final colDiff = (fromCol - toCol).abs();

  // King moves one square in any direction
  if (rowDiff <= 1 && colDiff <= 1) {
    return true;
  }

  // Castling
  if (!kingHasMoved && fromRow == toRow && colDiff == 2) {
    final kingColor = board.getPieceAt(fromRow, fromCol)!.color;

    // King-side castling
    if (toCol > fromCol) {
      // Squares between king and rook must be empty
      if (board.getPieceAt(fromRow, fromCol + 1) == null &&
          board.getPieceAt(fromRow, fromCol + 2) == null) {
        final rook = board.getPieceAt(fromRow, fromCol + 3);
        if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
          // King must not be in check, nor pass through or land on attacked squares
          if (!isKingInCheck(board, kingColor) &&
              !isKingInCheck(board.copy()..movePiece(fromRow, fromCol, fromRow, fromCol + 1), kingColor) &&
              !isKingInCheck(board.copy()..movePiece(fromRow, fromCol, fromRow, fromCol + 2), kingColor)) {
            return true;
          }
        }
      }
    }
    // Queen-side castling
    else if (toCol < fromCol) {
      if (board.getPieceAt(fromRow, fromCol - 1) == null &&
          board.getPieceAt(fromRow, fromCol - 2) == null &&
          board.getPieceAt(fromRow, fromCol - 3) == null) {
        final rook = board.getPieceAt(fromRow, fromCol - 4);
        if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
          if (!isKingInCheck(board, kingColor) &&
              !isKingInCheck(board.copy()..movePiece(fromRow, fromCol, fromRow, fromCol - 1), kingColor) &&
              !isKingInCheck(board.copy()..movePiece(fromRow, fromCol, fromRow, fromCol - 2), kingColor)) {
            return true;
          }
        }
      }
    }
  }

  return false;
}
}