import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../services/move_validator.dart';

class GameProvider extends ChangeNotifier {
  late ChessGame _game;
  final MoveValidator _moveValidator;

  GameProvider() : _moveValidator = MoveValidator() {
    _game = ChessGame();
  }

  ChessGame get game => _game;

  // Make a move if it's valid
  void makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = _game.board.getPieceAt(fromRow, fromCol);
    
    // Ensure the piece exists and belongs to the current player
    if (piece == null || piece.color != _game.currentTurn) {
      return;
    }

    // Validate the move
    if (!_moveValidator.isValidMove(_game.board, fromRow, fromCol, toRow, toCol, _game.currentTurn)) {
      return;
    }

    // Create move object
    final from = Position(row: fromRow, col: fromCol);
    final to = Position(row: toRow, col: toCol);
    final capturedPiece = _game.board.getPieceAt(toRow, toCol);
    
    // Check for special moves
    bool isCheck = false;
    bool isCheckmate = false;
    bool isCastling = false;
    bool isEnPassant = false;
    bool isPawnPromotion = false;
    PieceType? promotionPiece;
    
    // TODO: Implement special move detection
    
    // Create the move
    final move = Move(
      from: from,
      to: to,
      piece: piece,
      capturedPiece: capturedPiece,
      isCheck: isCheck,
      isCheckmate: isCheckmate,
      isCastling: isCastling,
      isEnPassant: isEnPassant,
      isPawnPromotion: isPawnPromotion,
      promotionPiece: promotionPiece,
    );
    
    // Execute the move
    _game.makeMove(move);
    
    // Notify listeners about the change
    notifyListeners();
  }

  // Reset the game to initial state
  void resetGame() {
    _game.reset();
    notifyListeners();
  }
}