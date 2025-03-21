import 'dart:math';
import 'dart:math' as math;
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
      body: Stack(
        children: [
          // Colorful spiral background
          const ColorfulSpiralBackground(),
          
          // Main game content
          Column(
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'SPIRALE DE L\'ÉCHEC',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'PixelArt',
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Timers and chessboard
              Expanded(
                child: Row(
                  children: [
                    // Timer for black player
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        '12:32',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'PixelArt',
                        ),
                      ),
                    ),
                    
                    // Chessboard
                    Expanded(
                      child: Center(
                        child: ChessBoardWidget(
                          board: Provider.of<GameProvider>(context).game.board,
                          onPieceMoved: (fromRow, fromCol, toRow, toCol) {
                            // Validate and execute the move
                            Provider.of<GameProvider>(context, listen: false).makeMove(fromRow, fromCol, toRow, toCol);
                          },
                        ),
                      ),
                    ),
                    
                    // Timer for white player
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        '15:56',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'PixelArt',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ColorfulSpiralBackground extends StatefulWidget {
  const ColorfulSpiralBackground({Key? key}) : super(key: key);

  @override
  _ColorfulSpiralBackgroundState createState() => _ColorfulSpiralBackgroundState();
}

class _ColorfulSpiralBackgroundState extends State<ColorfulSpiralBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _TornadoSpiralPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _TornadoSpiralPainter extends CustomPainter {
  final double animationValue;

  _TornadoSpiralPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    
    // Nombre de bras dans la spirale
    const int armCount = 8;
    
    // Couleurs vives pour les bras
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.amber,
    ];
    
    // Paramètres pour la spirale
    const double turns = 3.0; // Nombre de tours de la spirale
    const double armWidth = 25.0; // Largeur de chaque bras
    
    // Dessiner chaque bras de la spirale
    for (int i = 0; i < armCount; i++) {
      final armPhase = i * (math.pi * 2 / armCount);
      final rotationOffset = animationValue * math.pi * 2;
      
      final path = Path();
      bool firstPoint = true;
      
      // Points pour former le chemin du bras
      for (double t = 0.0; t <= 1.0; t += 0.005) {
        // Formule de la spirale avec rotation animée
        final angle = armPhase + turns * t * math.pi * 2 + rotationOffset;
        final radius = t * maxRadius;
        
        // Position sur la spirale
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        // Créer le chemin du bras
        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
      
      // Dessiner le bras avec un effet de dégradé
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = armWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, paint);
      
      // Ajouter des cercles le long du bras pour plus d'effet
      for (double t = 0.0; t <= 1.0; t += 0.1) {
        final angle = armPhase + turns * t * math.pi * 2 + rotationOffset;
        final radius = t * maxRadius;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        final dotPaint = Paint()
          ..color = colors[(i + 1) % colors.length]
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), armWidth / 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TornadoSpiralPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}