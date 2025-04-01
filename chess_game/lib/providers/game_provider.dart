import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../services/move_validator.dart';

class GameProvider extends ChangeNotifier {
  ChessGame _game = ChessGame();
  final MoveValidator _moveValidator;

  GameProvider() : _moveValidator = MoveValidator();

  ChessGame get game => _game;
  
  // Access the last move through the game
  Move? get lastMove => _game.lastMove;
  
  // Get move history
  List<Move> get moveHistory => _game.moveHistory;

  // Make a move if it's valid
  void makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = _game.board.getPieceAt(fromRow, fromCol);

    // Ensure the piece exists and belongs to the current player
    if (piece == null || piece.color != _game.currentTurn) {
      return;
    }

    // Check if this is a valid move (including en passant)
    final validMoves = _moveValidator.getValidMoves(
      _game.board, 
      fromRow, 
      fromCol, 
      _game.currentTurn,
      lastMove
    );
    
    final isValidMove = validMoves.any((move) => move[0] == toRow && move[1] == toCol);
    
    if (!isValidMove) {
      return;
    }

    // Execute the move
    _game.makeMove(fromRow, fromCol, toRow, toCol);
    
    // Notify listeners
    notifyListeners();
  }
  
  // Reset game
  void resetGame() {
    _game.reset();
    notifyListeners();
  }
}