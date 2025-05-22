import 'package:flutter/material.dart';
import '../models/piece.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;

  const ChessPieceWidget({
    Key? key,
    required this.piece,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For initial testing, use Unicode chess symbols
    String symbol = '';
    switch (piece.type) {
      case PieceType.king:
        symbol = piece.color == PieceColor.white ? '♔' : '♚';
        break;
      case PieceType.queen:
        symbol = piece.color == PieceColor.white ? '♕' : '♛';
        break;
      case PieceType.rook:
        symbol = piece.color == PieceColor.white ? '♖' : '♜';
        break;
      case PieceType.bishop:
        symbol = piece.color == PieceColor.white ? '♗' : '♝';
        break;
      case PieceType.knight:
        symbol = piece.color == PieceColor.white ? '♘' : '♞';
        break;
      case PieceType.pawn:
        symbol = piece.color == PieceColor.white ? '♙' : '♟';
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: size * 0.8,
            color: piece.color == PieceColor.white ? Colors.white : Colors.black,
            shadows: [
              Shadow(
                blurRadius: 3,
                color: piece.color == PieceColor.white ? Colors.black54 : Colors.white54,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );

    // When you have images, uncomment this
    /*
    return Image.asset(
      piece.imagePath,
      width: size,
      height: size,
    );
    */
  }
}