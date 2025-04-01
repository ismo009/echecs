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

    // Create a move object
    var move = Move(
      from: Position(row: fromRow, col: fromCol),
      to: Position(row: toRow, col: toCol),
      piece: piece,
      capturedPiece: capturedPiece,
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

    // Execute the move on the board
    board.movePiece(fromRow, fromCol, toRow, toCol);

    // Add to move history
    moveHistory.add(move);
    
    // Update last move
    lastMove = move;

    // Switch turn
    currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  // Reset the game to initial state
  void reset() {
    board.setupInitialPosition();
    moveHistory.clear();
    currentTurn = PieceColor.white;
    state = GameState.active;
    lastMove = null;
  }
}