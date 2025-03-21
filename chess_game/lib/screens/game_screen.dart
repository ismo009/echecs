import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chess_board.dart';
import '../widgets/move_history.dart';
import '../widgets/player_info.dart';
import '../models/game.dart';
import '../providers/game_provider.dart';
import '../models/piece.dart'; // Import PieceColor enum

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset the game
              Provider.of<GameProvider>(context, listen: false).resetGame();
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final game = gameProvider.game;
          
          return Column(
            children: [
              // Player info for the black player
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PlayerInfoWidget(
                  player: game.blackPlayer,
                  isCurrentTurn: game.currentTurn == PieceColor.black,
                  isInCheck: game.state == GameState.check && game.currentTurn == PieceColor.black,
                ),
              ),
              
              // Chessboard
              Expanded(
                child: Row(
                  children: [
                    // Chess board takes most of the space
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: ChessBoardWidget(
                          board: game.board,
                          onPieceMoved: (fromRow, fromCol, toRow, toCol) {
                            // Validate and execute the move
                            gameProvider.makeMove(fromRow, fromCol, toRow, toCol);
                          },
                        ),
                      ),
                    ),
                    
                    // Move history on the side
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MoveHistoryWidget(
                          moves: game.moveHistory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Player info for the white player
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PlayerInfoWidget(
                  player: game.whitePlayer,
                  isCurrentTurn: game.currentTurn == PieceColor.white,
                  isInCheck: game.state == GameState.check && game.currentTurn == PieceColor.white,
                ),
              ),
              
              // Game status bar
              if (game.state != GameState.active)
                Container(
                  color: game.state == GameState.checkmate ? Colors.red : Colors.amber,
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: Text(
                    _getGameStateMessage(game.state, game.currentTurn),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  String _getGameStateMessage(GameState state, PieceColor currentTurn) {
    switch (state) {
      case GameState.check:
        return 'Check!';
      case GameState.checkmate:
        final winner = currentTurn == PieceColor.white ? 'Black' : 'White';
        return 'Checkmate! $winner wins';
      case GameState.stalemate:
        return 'Stalemate - Draw';
      case GameState.draw:
        return 'Draw';
      case GameState.active:
      default:
        return '';
    }
  }
}