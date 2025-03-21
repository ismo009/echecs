import '../models/board.dart';
import '../models/piece.dart';
import '../utils/game_rules.dart';

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
  
  // Get all valid moves for a piece
  List<List<int>> getValidMoves(
    ChessBoard board,
    int row,
    int col,
    PieceColor currentTurn
  ) {
    final piece = board.getPieceAt(row, col);
    final validMoves = <List<int>>[];
    
    if (piece == null || piece.color != currentTurn) {
      return validMoves;
    }
    
    // Check all possible squares on the board
    for (int toRow = 0; toRow < 8; toRow++) {
      for (int toCol = 0; toCol < 8; toCol++) {
        if (isValidMove(board, row, col, toRow, toCol, currentTurn)) {
          validMoves.add([toRow, toCol]);
        }
      }
    }
    
    return validMoves;
  }
  
  // Check if the game is over
  bool isGameOver(ChessBoard board, PieceColor currentTurn) {
    // Check if current player has any valid moves
    for (int fromRow = 0; fromRow < 8; fromRow++) {
      for (int fromCol = 0; fromCol < 8; fromCol++) {
        final piece = board.getPieceAt(fromRow, fromCol);
        if (piece != null && piece.color == currentTurn) {
          // Check if this piece has any valid moves
          for (int toRow = 0; toRow < 8; toRow++) {
            for (int toCol = 0; toCol < 8; toCol++) {
              if (isValidMove(board, fromRow, fromCol, toRow, toCol, currentTurn)) {
                return false; // Player has at least one valid move
              }
            }
          }
        }
      }
    }
    
    // No valid moves found, game is over
    return true;
  }
  
  // Check if player is in checkmate
  bool isCheckmate(ChessBoard board, PieceColor color) {
    return GameRules.isKingInCheck(board, color) && isGameOver(board, color);
  }
  
  // Check if player is in stalemate
  bool isStalemate(ChessBoard board, PieceColor color) {
    return !GameRules.isKingInCheck(board, color) && isGameOver(board, color);
  }
}