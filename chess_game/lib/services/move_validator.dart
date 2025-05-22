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
    // Find the position of the king
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
    
    // Check if any opponent piece can capture the king
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPieceAt(row, col);
        if (piece != null && piece.color != kingColor) {
          // Ignore check validation to see if the piece can attack the king
          final canAttackKing = _canPieceAttack(board, row, col, kingRow, kingCol);
          if (canAttackKing) {
            return true;
          }
        }
      }
    }
    
    return false;
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
  
  // Méthode pour vérifier si un mouvement laisserait le roi en échec
  bool wouldLeaveKingInCheck(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol, PieceColor color) {
    // Créer une copie du plateau pour simuler le mouvement
    ChessBoard tempBoard = _copyBoard(board);
    
    // Simuler le mouvement
    final piece = tempBoard.getPieceAt(fromRow, fromCol);
    tempBoard.squares[toRow][toCol] = piece;
    tempBoard.squares[fromRow][fromCol] = null;
    
    // Vérifier si le roi est en échec après le mouvement simulé
    return isKingInCheck(tempBoard, color);
  }
  
  // Méthode pour copier l'état du plateau
  ChessBoard _copyBoard(ChessBoard original) {
    final copy = ChessBoard();
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = original.getPieceAt(row, col);
        if (piece != null) {
          // Créer une copie de la pièce
          copy.squares[row][col] = ChessPiece(
            type: piece.type,
            color: piece.color,
            hasMoved: piece.hasMoved,
          );
        } else {
          copy.squares[row][col] = null;
        }
      }
    }
    
    return copy;
  }
  
  // Vérifier si une pièce peut attaquer une position
  bool _canPieceAttack(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board.getPieceAt(fromRow, fromCol);
    if (piece == null) return false;
    
    switch (piece.type) {
      case PieceType.pawn:
        // Les pions attaquent diagonalement
        final direction = piece.color == PieceColor.white ? -1 : 1;
        return (fromRow + direction == toRow) && ((fromCol - 1 == toCol) || (fromCol + 1 == toCol));
        
      case PieceType.knight:
        final rowDiff = (fromRow - toRow).abs();
        final colDiff = (fromCol - toCol).abs();
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
        
      case PieceType.bishop:
        return _canMoveOnDiagonal(board, fromRow, fromCol, toRow, toCol);
        
      case PieceType.rook:
        return _canMoveOrthogonally(board, fromRow, fromCol, toRow, toCol);
        
      case PieceType.queen:
        return _canMoveOnDiagonal(board, fromRow, fromCol, toRow, toCol) || 
               _canMoveOrthogonally(board, fromRow, fromCol, toRow, toCol);
               
      case PieceType.king:
        // Le roi peut attaquer les cases adjacentes
        final rowDiff = (fromRow - toRow).abs();
        final colDiff = (fromCol - toCol).abs();
        return rowDiff <= 1 && colDiff <= 1;
    }
    
    return false;
  }
  
  // Vérifier le mouvement en diagonale (fou et reine)
  bool _canMoveOnDiagonal(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    final rowDiff = toRow - fromRow;
    final colDiff = toCol - fromCol;
    
    // Vérifier que c'est une diagonale
    if (rowDiff.abs() != colDiff.abs()) return false;
    
    final rowDir = rowDiff > 0 ? 1 : -1;
    final colDir = colDiff > 0 ? 1 : -1;
    
    int r = fromRow + rowDir;
    int c = fromCol + colDir;
    
    // Vérifier que le chemin est clair
    while (r != toRow && c != toCol) {
      if (board.getPieceAt(r, c) != null) {
        return false; // Chemin bloqué
      }
      r += rowDir;
      c += colDir;
    }
    
    return true;
  }
  
  // Vérifier le mouvement orthogonal (tour et reine)
  bool _canMoveOrthogonally(ChessBoard board, int fromRow, int fromCol, int toRow, int toCol) {
    if (fromRow != toRow && fromCol != toCol) return false;
    
    if (fromRow == toRow) {
      // Mouvement horizontal
      final start = fromCol < toCol ? fromCol + 1 : toCol + 1;
      final end = fromCol < toCol ? toCol : fromCol;
      for (int c = start; c < end; c++) {
        if (board.getPieceAt(fromRow, c) != null) {
          return false; // Chemin bloqué
        }
      }
    } else {
      // Mouvement vertical
      final start = fromRow < toRow ? fromRow + 1 : toRow + 1;
      final end = fromRow < toRow ? toRow : fromRow;
      for (int r = start; r < end; r++) {
        if (board.getPieceAt(r, fromCol) != null) {
          return false; // Chemin bloqué
        }
      }
    }
    
    return true;
  }
  
  // Get all valid moves for a piece
  List<List<int>> getValidMoves(
    ChessBoard board,
    int row,
    int col,
    PieceColor currentTurn,
    Move? lastMove
  ) {
    final List<List<int>> candidateMoves = _getBasicValidMoves(board, row, col, currentTurn, lastMove);
    final List<List<int>> validMoves = [];
    
    // Filtrer les mouvements qui laisseraient le roi en échec
    for (final move in candidateMoves) {
      if (!wouldLeaveKingInCheck(board, row, col, move[0], move[1], currentTurn)) {
        validMoves.add(move);
      }
    }
    
    return validMoves;
  }
  
  // Renommer l'ancienne méthode pour l'utiliser comme base
  List<List<int>> _getBasicValidMoves(
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

    switch (piece.type) {
      case PieceType.pawn:
        return _getPawnMoves(board, row, col, piece.color, lastMove);
      case PieceType.rook:
        return _getRookMoves(board, row, col, piece.color);
      case PieceType.knight:
        return _getKnightMoves(board, row, col, piece.color);
      case PieceType.bishop:
        return _getBishopMoves(board, row, col, piece.color);
      case PieceType.queen:
        return _getQueenMoves(board, row, col, piece.color);
      case PieceType.king:
        return _getKingMoves(board, row, col, piece.color);
      default:
        return [];
    }
  }

  List<List<int>> _getPawnMoves(ChessBoard board, int row, int col, PieceColor color, Move? lastMove) {
    final validMoves = <List<int>>[];
    final direction = color == PieceColor.white ? -1 : 1;
    final startRow = color == PieceColor.white ? 6 : 1;
    
    // Mouvement vers l'avant (une case)
    if (row + direction >= 0 && row + direction < 8 && 
        board.getPieceAt(row + direction, col) == null) {
      validMoves.add([row + direction, col]);
      
      // Mouvement double depuis la position initiale
      if (row == startRow && board.getPieceAt(row + 2 * direction, col) == null) {
        validMoves.add([row + 2 * direction, col]);
      }
    }
    
    // Captures diagonales
    for (int colOffset in [-1, 1]) {
      if (col + colOffset >= 0 && col + colOffset < 8 && 
          row + direction >= 0 && row + direction < 8) {
        final targetPiece = board.getPieceAt(row + direction, col + colOffset);
        if (targetPiece != null && targetPiece.color != color) {
          validMoves.add([row + direction, col + colOffset]);
        }
      }
    }
    
    // En passant
    if (lastMove != null && lastMove.piece?.type == PieceType.pawn) {
      if ((lastMove.from.row - lastMove.to.row).abs() == 2) { // Le pion s'est déplacé de 2 cases
        if (row == lastMove.to.row && (col - lastMove.to.col).abs() == 1) { // Même rang, colonne adjacente
          validMoves.add([row + direction, lastMove.to.col]);
        }
      }
    }
    
    return validMoves;
  }
  
  List<List<int>> _getRookMoves(ChessBoard board, int row, int col, PieceColor color) {
    final validMoves = <List<int>>[];
    
    // Directions: haut, droite, bas, gauche
    final directions = [[-1, 0], [0, 1], [1, 0], [0, -1]];
    
    for (var dir in directions) {
      int r = row + dir[0];
      int c = col + dir[1];
      
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final targetPiece = board.getPieceAt(r, c);
        if (targetPiece == null) {
          // Case vide, on peut s'y déplacer
          validMoves.add([r, c]);
        } else {
          // Pièce rencontrée
          if (targetPiece.color != color) {
            // Pièce ennemie, on peut la capturer
            validMoves.add([r, c]);
          }
          // On arrête dans cette direction
          break;
        }
        r += dir[0];
        c += dir[1];
      }
    }
    
    return validMoves;
  }
  
  List<List<int>> _getKnightMoves(ChessBoard board, int row, int col, PieceColor color) {
    final validMoves = <List<int>>[];
    
    // Les 8 mouvements possibles pour le cavalier
    final moves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    
    for (var move in moves) {
      int r = row + move[0];
      int c = col + move[1];
      
      if (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final targetPiece = board.getPieceAt(r, c);
        if (targetPiece == null || targetPiece.color != color) {
          validMoves.add([r, c]);
        }
      }
    }
    
    return validMoves;
  }
  
  List<List<int>> _getBishopMoves(ChessBoard board, int row, int col, PieceColor color) {
    final validMoves = <List<int>>[];
    
    // Directions diagonales: haut-gauche, haut-droite, bas-droite, bas-gauche
    final directions = [[-1, -1], [-1, 1], [1, 1], [1, -1]];
    
    for (var dir in directions) {
      int r = row + dir[0];
      int c = col + dir[1];
      
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final targetPiece = board.getPieceAt(r, c);
        if (targetPiece == null) {
          // Case vide
          validMoves.add([r, c]);
        } else {
          // Pièce rencontrée
          if (targetPiece.color != color) {
            // Pièce ennemie
            validMoves.add([r, c]);
          }
          // On arrête dans cette direction
          break;
        }
        r += dir[0];
        c += dir[1];
      }
    }
    
    return validMoves;
  }
  
  List<List<int>> _getQueenMoves(ChessBoard board, int row, int col, PieceColor color) {
    // La reine combine les mouvements de la tour et du fou
    final rookMoves = _getRookMoves(board, row, col, color);
    final bishopMoves = _getBishopMoves(board, row, col, color);
    return [...rookMoves, ...bishopMoves];
  }
  
  List<List<int>> _getKingMoves(ChessBoard board, int row, int col, PieceColor color) {
    final validMoves = <List<int>>[];
    
    // Toutes les cases adjacentes
    for (int r = -1; r <= 1; r++) {
      for (int c = -1; c <= 1; c++) {
        // Ignorer la position actuelle
        if (r == 0 && c == 0) continue;
        
        int newRow = row + r;
        int newCol = col + c;
        
        if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
          final targetPiece = board.getPieceAt(newRow, newCol);
          if (targetPiece == null || targetPiece.color != color) {
            validMoves.add([newRow, newCol]);
          }
        }
      }
    }
    
    // Rochade (Castling)
    final piece = board.getPieceAt(row, col);
    if (piece != null && !piece.hasMoved) {
      // Vérifier les deux côtés pour la rochade
      // Côté roi
      if (col + 2 < 8) {
      final rook = board.getPieceAt(row, col + 3);
      if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
        // Vérifier que les cases entre le roi et la tour sont vides
        if (board.getPieceAt(row, col + 1) == null &&
          board.getPieceAt(row, col + 2) == null) {
        // Vérifier que le roi ne passe pas par une case attaquée
        if (!isKingInCheck(board, color) &&
          !wouldLeaveKingInCheck(board, row, col, row, col + 1, color) &&
          !wouldLeaveKingInCheck(board, row, col, row, col + 2, color)) {
          validMoves.add([row, col + 2]);
        }
        }
      }
      }

      // Côté dame
      if (col - 2 >= 0) {
      final rook = board.getPieceAt(row, col - 4);
      if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
        // Vérifier que les cases entre le roi et la tour sont vides
        if (board.getPieceAt(row, col - 1) == null &&
          board.getPieceAt(row, col - 2) == null &&
          board.getPieceAt(row, col - 3) == null) {
        // Vérifier que le roi ne passe pas par une case attaquée
        if (!isKingInCheck(board, color) &&
          !wouldLeaveKingInCheck(board, row, col, row, col - 1, color) &&
          !wouldLeaveKingInCheck(board, row, col, row, col - 2, color)) {
          validMoves.add([row, col - 2]);
        }
        }
      }
      }
    }
    
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