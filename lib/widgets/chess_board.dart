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
  final bool enabled; // <-- Ajoute cette ligne

  const ChessBoardWidget({
    Key? key,
    required this.board,
    required this.onPieceMoved,
    this.highlightedSquares,
    this.enabled = true, // <-- Ajoute cette ligne (valeur par défaut)
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
                      child: ChessPieceWidget(
                        piece: piece,
                        size: squareSize * 0.8,
                      ),
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
    if (!widget.enabled) return; // <-- Ajoute cette ligne
    // Get access to the game provider for move validation
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentTurn = gameProvider.game.currentTurn;
    final moveValidator = MoveValidator();
    
    // If no piece is selected yet
    if (_selectedRow == null) {
      final piece = widget.board.getPieceAt(row, col);
      if (piece != null && piece.color == currentTurn) {
        // Get valid moves for this piece
        _validMoves = moveValidator.getValidMoves(widget.board, row, col, currentTurn);
        
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
        // Execute the move
        widget.onPieceMoved(_selectedRow!, _selectedCol!, row, col);
      } else {
        // Check if selecting a different piece of the same color
        final piece = widget.board.getPieceAt(row, col);
        if (piece != null && piece.color == currentTurn) {
          // Get valid moves for the new piece
          _validMoves = moveValidator.getValidMoves(widget.board, row, col, currentTurn);
          
          setState(() {
            _selectedRow = row;
            _selectedCol = col;
          });
          return;
        }
      }
      
      // Clear selection and valid moves
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
        _validMoves = [];
      });
    }
  }
}