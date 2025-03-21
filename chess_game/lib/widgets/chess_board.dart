import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/piece.dart';
import 'chess_piece.dart';

class ChessBoardWidget extends StatefulWidget {
  final ChessBoard board;
  final Function(int, int, int, int) onPieceMoved;
  final List<List<bool>> highlightedSquares;

  const ChessBoardWidget({
    Key? key,
    required this.board,
    required this.onPieceMoved,
    this.highlightedSquares = const [],
  }) : super(key: key);

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  int? _selectedRow;
  int? _selectedCol;

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
            final isHighlighted = widget.highlightedSquares.isNotEmpty && 
                                  widget.highlightedSquares.length > row && 
                                  widget.highlightedSquares[row].length > col && 
                                  widget.highlightedSquares[row][col];

            return GestureDetector(
              onTap: () => _handleTap(row, col),
              child: Stack(
                children: [
                  // Square
                  Container(
                    color: isSelected
                        ? Colors.green.shade300
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
                  
                  // Piece
                  if (piece != null)
                    Center(
                      child: ChessPieceWidget(
                        piece: piece,
                        size: squareSize * 0.8,
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
    // If no piece is selected yet
    if (_selectedRow == null) {
      final piece = widget.board.getPieceAt(row, col);
      if (piece != null) {
        setState(() {
          _selectedRow = row;
          _selectedCol = col;
        });
      }
    } else {
      // A piece was already selected, attempt to move it
      if (_selectedRow != row || _selectedCol != col) {
        widget.onPieceMoved(_selectedRow!, _selectedCol!, row, col);
      }
      
      // Clear selection
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
      });
    }
  }
}