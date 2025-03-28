import 'package:flutter/material.dart';
import '../models/piece.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
    // Création du chemin de l'image basé sur le type et la couleur de la pièce
    String pieceColor = piece.color == PieceColor.white ? 'w' : 'b';
    String pieceType = '';
    
    switch (piece.type) {
      case PieceType.king:
        pieceType = 'king';
        break;
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
      case PieceType.pawn:
        pieceType = 'pawn';
        break;
    }
    
    // Construction du chemin complet de l'image
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
          // En cas d'erreur (image non trouvée), utiliser l'image par défaut
          return Image.asset(
            'assets/images/pieces/default.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }
}