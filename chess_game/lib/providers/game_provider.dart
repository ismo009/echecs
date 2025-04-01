import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../services/move_validator.dart';

class GameProvider extends ChangeNotifier {
  ChessGame _game = ChessGame();
  final MoveValidator _moveValidator;
  bool _isKingInCheck = false;

  GameProvider() : _moveValidator = MoveValidator();

  ChessGame get game => _game;
  
  // Accès au dernier mouvement
  Move? get lastMove => _game.lastMove;
  
  // Obtenir l'historique des mouvements
  List<Move> get moveHistory => _game.moveHistory;
  
  // Vérifier si une promotion est en attente
  bool get isPromotionPending => _game.isPromotionPending;
  
  // Vérifier si le roi est en échec
  bool get isKingInCheck => _isKingInCheck;

  // Effectuer un mouvement s'il est valide
  void makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = _game.board.getPieceAt(fromRow, fromCol);

    // S'assurer que la pièce existe et appartient au joueur actuel
    if (piece == null || piece.color != _game.currentTurn) {
      return;
    }

    // Vérifier si le mouvement laisserait le roi en échec
    if (_moveValidator.wouldLeaveKingInCheck(_game.board, fromRow, fromCol, toRow, toCol, _game.currentTurn)) {
      // Ne pas permettre le mouvement
      return;
    }

    // Vérifier la validité du mouvement (y compris en passant)
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

    // Exécuter le mouvement
    _game.makeMove(fromRow, fromCol, toRow, toCol);
    
    // Vérifier si le roi adverse est en échec après ce mouvement
    PieceColor opponentColor = _game.currentTurn; // déjà changé dans makeMove
    _isKingInCheck = _moveValidator.isKingInCheck(_game.board, opponentColor);
    
    // Notifier les auditeurs
    notifyListeners();
  }
  
  // Promouvoir un pion
  void promotePawn(PieceType promotionType) {
    _game.promotePawn(promotionType);
    
    // Vérifier si le roi adverse est en échec après la promotion
    PieceColor opponentColor = _game.currentTurn;
    _isKingInCheck = _moveValidator.isKingInCheck(_game.board, opponentColor);
    
    notifyListeners();
  }
  
  // Réinitialiser le jeu
  void resetGame() {
    _game.reset();
    _isKingInCheck = false;
    notifyListeners();
  }
}