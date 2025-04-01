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
<<<<<<< Updated upstream
    // For initial testing, use Unicode chess symbols
    String symbol = '';
=======
    //Creation du path vers la texture de la piece
    String pieceColor = piece.color == PieceColor.white ? 'w' : 'b';
    String pieceType = '';
    
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

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
=======
    
    //Chemin complet
    String imagePath = 'assets/images/pieces/${pieceType}.${pieceColor}.png';
    
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          //Imafe debug, insipiré du debug model de Source
          return Image.asset(
            'assets/images/pieces/default.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        },
>>>>>>> Stashed changes
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