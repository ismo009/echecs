import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/piece.dart';

class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final bool isInCheck;

  const PlayerInfoWidget({
    Key? key,
    required this.player,
    this.isCurrentTurn = false,
    this.isInCheck = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = player.timeRemaining ~/ 60;
    final seconds = player.timeRemaining % 60;
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isCurrentTurn ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isInCheck ? Colors.red : isCurrentTurn ? Colors.blue : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: player.color == PieceColor.white ? Colors.white : Colors.black,
            child: player.color == PieceColor.white 
                ? const Icon(Icons.person, color: Colors.black)
                : const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isInCheck)
                  const Text(
                    'CHECK!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}