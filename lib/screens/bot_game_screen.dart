import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockfish_chess_engine/stockfish_chess_engine.dart';
import '../models/game.dart';
import '../widgets/chess_board.dart';
import '../models/piece.dart';
import '../models/move.dart';

class BotGameScreen extends StatefulWidget {
  final int skillLevel;

  const BotGameScreen({Key? key, required this.skillLevel}) : super(key: key);

  @override
  State<BotGameScreen> createState() => _BotGameScreenState();
}

class _BotGameScreenState extends State<BotGameScreen> {
  late ChessGame _game;
  late Stockfish _stockfish;
  late StreamSubscription _stockfishOutputSubscription;
  bool _isBotThinking = false;
  String _bestMove = '';

  late int _botSkillLevel; // Valeur par défaut (de 0 à 20 pour Stockfish)

  @override
  void initState() {
    super.initState();
    _game = ChessGame();
    _stockfish = Stockfish();
    _stockfishOutputSubscription = _stockfish.stdout.listen(_onStockfishOutput);
    _botSkillLevel = widget.skillLevel;
    _startStockfish();
  }

  @override
  void dispose() {
    _stockfishOutputSubscription.cancel();
    _stockfish.dispose();
    super.dispose();
  }

  Future<void> _startStockfish() async {
    try {
      // Attendre que Stockfish soit réellement prêt
      await Future.delayed(const Duration(seconds: 2));
      
      // Vérifier l'état avant d'envoyer des commandes
      if (_stockfish.state != 'ready') {
        await Future.delayed(const Duration(seconds: 3));
        if (_stockfish.state != 'ready') {
          print("Stockfish n'est toujours pas prêt: ${_stockfish.state}");
          return;
        }
      }
      
      _stockfish.stdin = 'uci';
      await Future.delayed(const Duration(milliseconds: 500));
      
      _stockfish.stdin = 'isready';
      bool isReady = await _waitForReadyOk();
      if (!isReady) {
        print("Stockfish n'a pas répondu avec 'readyok'");
        return;
      }
      
      _stockfish.stdin = 'setoption name Skill Level value $_botSkillLevel';
      await Future.delayed(const Duration(milliseconds: 500));
      
      // NE PAS envoyer de position ici - attendez le premier coup
      print("Stockfish initialized successfully");
    } catch (e) {
      print("Error initializing Stockfish: $e");
    }
  }

  Future<bool> _waitForReadyOk() async {
    Completer<bool> completer = Completer<bool>();
    late StreamSubscription sub;
    
    // Timeout après 5 secondes
    Timer timer = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete(false);
        sub.cancel();
      }
    });
    
    sub = _stockfish.stdout.listen((output) {
      if (output.contains('readyok')) {
        if (!completer.isCompleted) {
          completer.complete(true);
          timer.cancel();
        }
      }
    });
    
    bool result = await completer.future;
    sub.cancel();
    return result;
  }

  void _onStockfishOutput(String output) {
    print("Stockfish output: $output");
    
    if (output.startsWith('bestmove')) {
      final parts = output.split(' ');
      setState(() {
        _bestMove = parts.length > 1 ? parts[1] : '(none)';
      });
      if (_bestMove != '(none)' && _bestMove.length >= 4) {
        _playBotMove(_bestMove);
      }
      setState(() => _isBotThinking = false);
    }
  }

  Future<void> _onPlayerMove(int fromRow, int fromCol, int toRow, int toCol, [PieceType? promotion]) async {
    if (_isBotThinking) return;
  
    setState(() {
      final piece = _game.board.getPieceAt(fromRow, fromCol);
      final capturedPiece = _game.board.getPieceAt(toRow, toCol);
      final isPawnPromotion = piece?.type == PieceType.pawn && (toRow == 0 || toRow == 7);

      final move = Move(
        from: Position(row: fromRow, col: fromCol),
        to: Position(row: toRow, col: toCol),
        piece: piece,
        capturedPiece: capturedPiece,
        isPawnPromotion: isPawnPromotion,
        promotionPiece: promotion,
      );
      _game.makeMove(move);
    });

    if (!_game.isGameOver()) {
      setState(() => _isBotThinking = true);
      final fen = _game.toFEN();
      
      // Vérification approfondie du FEN
      if (!_isValidFEN(fen)) {
        print("FEN invalide généré: $fen");
        setState(() => _isBotThinking = false);
        return;
      }
      
      // Log du FEN pour débogage
      print("Envoi du FEN à Stockfish: $fen");
      
      try {
        _stockfish.stdin = 'position fen $fen';
        await Future.delayed(const Duration(milliseconds: 100));
        _stockfish.stdin = 'go movetime 1000';
      } catch (e) {
        print("Erreur lors de l'envoi de commandes à Stockfish: $e");
        setState(() => _isBotThinking = false);
      }
    }
  }

  // Ajouter cette méthode pour valider le FEN
  bool _isValidFEN(String fen) {
    // Vérification plus complète du FEN
    if (fen.isEmpty) return false;
  
    // Vérifier la présence des deux rois
    bool hasWhiteKing = fen.contains('K');
    bool hasBlackKing = fen.contains('k');
  
    // Vérifier la structure de base du FEN (au moins 4 sections séparées par des espaces)
    List<String> parts = fen.split(' ');
    bool hasValidStructure = parts.length >= 4;
  
    // Vérifier que le côté qui joue est valide
    bool hasSideToMove = parts.length > 1 && (parts[1] == 'w' || parts[1] == 'b');
  
    return hasWhiteKing && hasBlackKing && hasValidStructure && hasSideToMove;
  }

  void _playBotMove(String move) {
    // move format: e2e4 or e7e8q (promotion)
    int fCol = move.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int fRow = 8 - int.parse(move[1]);
    int tCol = move.codeUnitAt(2) - 'a'.codeUnitAt(0);
    int tRow = 8 - int.parse(move[3]);
    PieceType? promotion;
    if (move.length == 5) {
      switch (move[4]) {
        case 'q': promotion = PieceType.queen; break;
        case 'r': promotion = PieceType.rook; break;
        case 'b': promotion = PieceType.bishop; break;
        case 'n': promotion = PieceType.knight; break;
      }
    }
    setState(() {
      final piece = _game.board.getPieceAt(fRow, fCol);
      final capturedPiece = _game.board.getPieceAt(tRow, tCol);
      final isPawnPromotion = piece?.type == PieceType.pawn && (tRow == 0 || tRow == 7);

      final move = Move(
        from: Position(row: fRow, col: fCol),
        to: Position(row: tRow, col: tCol),
        piece: piece,
        capturedPiece: capturedPiece,
        isPawnPromotion: isPawnPromotion,
        promotionPiece: promotion,
      );
      _game.makeMove(move);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jouer contre le Bot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: _botSkillLevel,
              items: List.generate(21, (i) => DropdownMenuItem(
                value: i,
                child: Text('Difficulté $i'),
              )),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _botSkillLevel = value;
                  });
                  // Si tu veux changer la difficulté en cours de partie :
                  _stockfish.stdin = 'setoption name Skill Level value $value';
                }
              },
            ),
            ChessBoardWidget(
              board: _game.board,
              onPieceMoved: _onPlayerMove,
              enabled: !_isBotThinking,
            ),
          ],
        ),
      ),
    );
  }
}

// À placer dans la page où tu proposes de jouer contre le bot
void _showDifficultyDialog(BuildContext context) async {
  int selectedLevel = 5;
  final result = await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Choisir la difficulté du bot'),
        content: DropdownButton<int>(
          value: selectedLevel,
          items: List.generate(21, (i) => DropdownMenuItem(
            value: i,
            child: Text('Difficulté $i'),
          )),
          onChanged: (value) {
            if (value != null) {
              selectedLevel = value;
              Navigator.of(context).pop(selectedLevel);
            }
          },
        ),
      );
    },
  );
  if (result != null) {
    // Navigue vers l'écran du bot en passant la difficulté choisie
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BotGameScreen(skillLevel: result),
      ),
    );
  }
}