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

    moveHistory.add(move);

    currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;

  }

  // Reset the game to initial state
  void reset() {
    board.setupInitialPosition();
    moveHistory.clear();
    currentTurn = PieceColor.white;
    state = GameState.active;
  }
  String toFEN() {
    final fenBuffer = StringBuffer();

    // Generate board FEN
    for (int row = 0; row < 8; row++) {
      int emptyCount = 0;
      for (int col = 0; col < 8; col++) {
        final piece = board.getPieceAt(row, col);
        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fenBuffer.write(emptyCount);
            emptyCount = 0;
          }
          fenBuffer.write(piece.toFENSymbol());
        }
      }
      if (emptyCount > 0) {
        fenBuffer.write(emptyCount);
      }
      if (row < 7) {
        fenBuffer.write('/');
      }
    }

    // Add current turn
    fenBuffer.write(' ');
    fenBuffer.write(currentTurn == PieceColor.white ? 'w' : 'b');

    // Add placeholders for castling rights, en passant, halfmove clock, and fullmove number
    fenBuffer.write(' - - 0 ${moveHistory.length ~/ 2 + 1}');

    final fen = fenBuffer.toString();
    // Vérification simple
    if (!fen.contains('K') || !fen.contains('k')) {
      throw Exception('FEN invalide : il manque un roi !');
    }
    return fen;
  }
  
  bool isGameOver() {
    return state == GameState.checkmate ||
           state == GameState.stalemate ||
           state == GameState.draw;
  }
}