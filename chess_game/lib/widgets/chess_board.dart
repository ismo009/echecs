import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../models/piece.dart';
import '../providers/game_provider.dart';
import '../services/move_validator.dart';
import 'chess_piece.dart';

class ChessBoardWidget extends StatefulWidget {
  final ChessBoard board;
  final Function(int, int, int, int) onPieceMoved;
  final List<List<bool>>? highlightedSquares;

  const ChessBoardWidget({
    Key? key,
    required this.board,
    required this.onPieceMoved,
    this.highlightedSquares,
  }) : super(key: key);

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  int? _selectedRow;
  int? _selectedCol;
  List<List<int>> _validMoves = [];

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    // Vérification de promotion en attente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameProvider.isPromotionPending) {
        _showPromotionDialog(context);
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth > 600 ? 600.0 : screenWidth - 32;
    final squareSize = boardSize / 8;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final isWhiteSquare = (row + col) % 2 == 0;
            final piece = widget.board.getPieceAt(row, col);
            final isSelected = _selectedRow == row && _selectedCol == col;

            // Check if square is a valid move
            final isValidMove = _validMoves.any((move) => move[0] == row && move[1] == col);

            // Check if square is highlighted
            final isHighlighted = widget.highlightedSquares != null &&
                row < widget.highlightedSquares!.length &&
                col < widget.highlightedSquares![row].length &&
                widget.highlightedSquares![row][col];

            return GestureDetector(
              onTap: () => _handleTap(row, col),
              child: Stack(
                children: [
                  // Square
                  Container(
                    color: isSelected
                        ? Colors.green.shade300
                        : isValidMove
                            ? Colors.green.shade100
                            : isHighlighted
                                ? Colors.yellow.shade200
                                : isWhiteSquare
                                    ? Colors.white
                                    : Colors.brown.shade400,
                    width: squareSize,
                    height: squareSize,
                  ),

                  // Rank and file labels
                  if (col == 0)
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Text(
                        '${8 - row}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isWhiteSquare ? Colors.brown.shade400 : Colors.white,
                        ),
                      ),
                    ),
                  if (row == 7)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Text(
                        String.fromCharCode('a'.codeUnitAt(0) + col),
                        style: TextStyle(
                          fontSize: 10,
                          color: isWhiteSquare ? Colors.brown.shade400 : Colors.white,
                        ),
                      ),
                    ),

                  // Valid move indicator
                  if (isValidMove && piece == null)
                    Center(
                      child: Container(
                        width: squareSize * 0.3,
                        height: squareSize * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  // Piece
                  if (piece != null)
                    Center(
                      child: _buildPiece(row, col),
                    ),

                  // Valid capture indicator
                  if (isValidMove && piece != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(squareSize / 2),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleTap(int row, int col) {
    // Get access to the game provider for move validation
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentTurn = gameProvider.game.currentTurn;
    final moveValidator = MoveValidator();
    final lastMove = gameProvider.lastMove; // Access lastMove through provider

    // If no piece is selected yet
    if (_selectedRow == null) {
      final piece = widget.board.getPieceAt(row, col);
      if (piece != null && piece.color == currentTurn) {
        // Get valid moves for this piece
        _validMoves = moveValidator.getValidMoves(widget.board, row, col, currentTurn, lastMove);

        setState(() {
          _selectedRow = row;
          _selectedCol = col;
        });
      }
    } else {
      // A piece was already selected
      // Check if the tap is on a valid move
      final isValidMove = _validMoves.any((move) => move[0] == row && move[1] == col);

      if (isValidMove) {
        // Execute the move through the provider
        widget.onPieceMoved(_selectedRow!, _selectedCol!, row, col);

        setState(() {
          _selectedRow = null;
          _selectedCol = null;
          _validMoves = [];
        });
      } else {
        // Check if selecting a different piece of the same color
        final piece = widget.board.getPieceAt(row, col);
        if (piece != null && piece.color == currentTurn) {
          // Get valid moves for the new piece
          _validMoves = moveValidator.getValidMoves(widget.board, row, col, currentTurn, lastMove);

          setState(() {
            _selectedRow = row;
            _selectedCol = col;
          });
          return;
        }

        // Clear selection if clicking elsewhere
        setState(() {
          _selectedRow = null;
          _selectedCol = null;
          _validMoves = [];
        });
      }
    }
  }

  void _showPromotionDialog(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentColor = gameProvider.game.currentTurn;

    // Évite d'afficher le dialogue plusieurs fois
    if (!gameProvider.isPromotionPending) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Promouvoir le pion'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _promotionButton(context, PieceType.queen, currentColor),
              _promotionButton(context, PieceType.rook, currentColor),
              _promotionButton(context, PieceType.bishop, currentColor),
              _promotionButton(context, PieceType.knight, currentColor),
            ],
          ),
        );
      },
    );
  }

  Widget _promotionButton(BuildContext context, PieceType type, PieceColor color) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // Nommer le type de pièce
    String pieceType = '';
    switch (type) {
      case PieceType.queen:
        pieceType = 'queen';
        break;
      case PieceType.rook:
        pieceType = 'rook';
        break;
      case PieceType.bishop:
        pieceType = 'bishop';
        break;
      case PieceType.knight:
        pieceType = 'knight';
        break;
      default:
        pieceType = 'pawn';
    }
    
    // Couleur de la pièce
    String pieceColor = color == PieceColor.white ? 'w' : 'b';
    
    // Chemin complet
    String imagePath = 'assets/images/pieces/${pieceType}.${pieceColor}.png';
    
    return InkWell(
      onTap: () {
        gameProvider.promotePawn(type);
        Navigator.of(context).pop();
      },
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          imagePath,
          width: 45,
          height: 45,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/pieces/default.png',
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPiece(int row, int col) {
    final piece = widget.board.getPieceAt(row, col);
    if (piece == null) return Container();
    
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final isCheck = gameProvider.isKingInCheck && 
                     piece.type == PieceType.king && 
                     piece.color == gameProvider.game.currentTurn;
    
    // Utilisation du widget ChessPieceWidget pour la cohérence
    return Stack(
      alignment: Alignment.center,
      children: [
        ChessPieceWidget(
          piece: piece,
          size: MediaQuery.of(context).size.width > 600 ? 
                600 / 8 - 10 : 
                (MediaQuery.of(context).size.width - 32) / 8 - 10,
        ),
        if (isCheck)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      ],
    );
  }

  String _getPieceName(PieceType type) {
    switch (type) {
      case PieceType.pawn: return 'pawn';
      case PieceType.rook: return 'rook';
      case PieceType.knight: return 'knight';
      case PieceType.bishop: return 'bishop';
      case PieceType.queen: return 'queen';
      case PieceType.king: return 'king';
    }
  }
}