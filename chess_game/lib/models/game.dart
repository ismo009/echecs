import 'board.dart';
import 'move.dart';
import 'piece.dart';
import 'player.dart';
import 'position.dart';

enum GameState { active, check, checkmate, stalemate, draw }

class ChessGame {
  final ChessBoard board;
  final Player whitePlayer;
  final Player blackPlayer;
  final List<Move> moveHistory;
  PieceColor currentTurn;
  GameState state;
  Move? lastMove;
  
  // Add these properties for promotion
  bool isPromotionPending = false;
  Position? promotionPosition;

  ChessGame({
    ChessBoard? board,
    Player? whitePlayer,
    Player? blackPlayer,
  })  : board = board ?? ChessBoard(),
        whitePlayer = whitePlayer ?? Player(name: 'White', color: PieceColor.white),
        blackPlayer = blackPlayer ?? Player(name: 'Black', color: PieceColor.black),
        moveHistory = [],
        currentTurn = PieceColor.white,
        state = GameState.active;

  Player get currentPlayer => currentTurn == PieceColor.white ? whitePlayer : blackPlayer;

  void makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board.getPieceAt(fromRow, fromCol);
    final capturedPiece = board.getPieceAt(toRow, toCol);
    
    if (piece == null) return;

    // Check for pawn promotion
    bool shouldPromote = false;
    if (piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && toRow == 0) || 
          (piece.color == PieceColor.black && toRow == 7)) {
        shouldPromote = true;
      }
    }

    // Create a move object
    var move = Move(
      from: Position(row: fromRow, col: fromCol),
      to: Position(row: toRow, col: toCol),
      piece: piece,
      capturedPiece: capturedPiece,
      isPromotion: shouldPromote,
    );

    // Handle en passant capture
    bool isEnPassantCapture = false;
    if (piece.type == PieceType.pawn && 
        lastMove != null &&
        lastMove!.piece?.type == PieceType.pawn &&
        ((lastMove!.from.row - lastMove!.to.row).abs() == 2) &&
        toCol == lastMove!.to.col &&
        fromRow == lastMove!.to.row &&
        toRow == lastMove!.to.row + (piece.color == PieceColor.white ? -1 : 1)) {
      
      // Mark this move as en passant
      move = Move(
        from: Position(row: fromRow, col: fromCol),
        to: Position(row: toRow, col: toCol),
        piece: piece,
        capturedPiece: board.getPieceAt(lastMove!.to.row, lastMove!.to.col),
        isEnPassant: true,
      );
      
      // Remove the captured pawn
      board.squares[lastMove!.to.row][lastMove!.to.col] = null;
      isEnPassantCapture = true;
    }

    bool isAPiece(row, col) {
      return board.getPieceAt(row, col) != null;
    }

    // Execute move on board
    board.movePiece(fromRow, fromCol, toRow, toCol);

    // Handle promotion
    if (shouldPromote) {
      isPromotionPending = true;
      promotionPosition = Position(row: toRow, col: toCol);
      
      // Add move to history
      moveHistory.add(move);
      lastMove = move;
      
      // Don't change turn yet, wait for promotion choice
      return;
    }

    // Add to move history
    moveHistory.add(move);
    
    // Update last move
    lastMove = move;

    // Switch turn
    currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  // Add this method for pawn promotion
  void promotePawn(PieceType promotionType) {
    if (!isPromotionPending || promotionPosition == null) return;
    
    int row = promotionPosition!.row;
    int col = promotionPosition!.col;
    
    // Get the pawn to be promoted
    ChessPiece? pawn = board.getPieceAt(row, col);
    
    if (pawn == null || pawn.type != PieceType.pawn) return;
    
    // Create the promoted piece
    ChessPiece promotedPiece = ChessPiece(
      type: promotionType,
      color: pawn.color,
      hasMoved: true,
    );
    
    // Replace the pawn on the board
    board.squares[row][col] = promotedPiece;
    
    // Update the last move with promotion info
    if (lastMove != null) {
      Move updatedMove = Move(
        from: lastMove!.from,
        to: lastMove!.to,
        piece: lastMove!.piece,
        capturedPiece: lastMove!.capturedPiece,
        isEnPassant: lastMove!.isEnPassant,
        isPromotion: true,
        promotionPiece: promotionType,
      );
      
      if (moveHistory.isNotEmpty) {
        moveHistory.removeLast();
        moveHistory.add(updatedMove);
      }
      
      lastMove = updatedMove;
    }
    
    // Reset promotion state
    isPromotionPending = false;
    promotionPosition = null;
    
    // Now switch the turn
    currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  // Reset the game
  void reset() {
    board.setupInitialPosition();
    moveHistory.clear();
    currentTurn = PieceColor.white;
    state = GameState.active;
    lastMove = null;
    isPromotionPending = false;
    promotionPosition = null;
  }
}