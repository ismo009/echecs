import 'package:flutter/material.dart';
import '../models/move.dart';

class MoveHistoryWidget extends StatelessWidget {
  final List<Move> moves;

  const MoveHistoryWidget({
    Key? key,
    required this.moves,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Expanded(
            child: moves.isEmpty
                ? const Center(child: Text('No moves yet'))
                : ListView.builder(
                    itemCount: (moves.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final moveNumber = index + 1;
                      final whiteIndex = index * 2;
                      final blackIndex = whiteIndex + 1;
                      
                      return Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '$moveNumber.',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              whiteIndex < moves.length
                                  ? moves[whiteIndex].toAlgebraicNotation()
                                  : '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              blackIndex < moves.length
                                  ? moves[blackIndex].toAlgebraicNotation()
                                  : '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}