import 'board.dart';
import 'move.dart';
import 'player.dart';
import 'piece.dart';

enum GameState { active, check, checkmate, stalemate, draw }

class ChessGame {
  final ChessBoard board;
  final Player whitePlayer;
  final Player blackPlayer;
  final List<Move> moveHistory;
  PieceColor currentTurn;
  GameState state;

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

  void makeMove(Move move) {
    // Execute the move on the board
    board.movePiece(
      move.from.row,
      move.from.col,
      move.to.row,
      move.to.col,
    );

    // Add to move history
    moveHistory.add(move);

    // Switch turn
    currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Update game state
    // This would be implemented with the move validator service
    // state = _determineGameState();
  }

  // Reset the game to initial state
  void reset() {
    board.setupInitialPosition();
    moveHistory.clear();
    currentTurn = PieceColor.white;
    state = GameState.active;
  }
}