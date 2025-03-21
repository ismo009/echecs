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
          //Spirale de fond
          const ColorfulSpiralBackground(),
          
          //Effet de CRT sur le background
          const CRTScanLinesEffect(),
          
          //Le jeux d'échecs
          Column(
            children: [
              //Nom du jeux
                Padding(
                padding: const EdgeInsets.only(top: 50.0), //50 pour éviter que la caméra soit sur le texte
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                  'SPIRALE DE L\'ÉCHEC', //Kastellik avait peut-etre raison...
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'PixelArt', //Chercher plus tard une meilleure + proche de Balatro
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
                ),
              
              //Timers + plateau
              Expanded(
                child: Row(
                  children: [
                    //Timer noir
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

// Widget pour l'effet des lignes de scan CRT
class CRTScanLinesEffect extends StatefulWidget {
  const CRTScanLinesEffect({Key? key}) : super(key: key);

  @override
  _CRTScanLinesEffectState createState() => _CRTScanLinesEffectState();
}

class _CRTScanLinesEffectState extends State<CRTScanLinesEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
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
          painter: _CRTScanLinesPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _CRTScanLinesPainter extends CustomPainter {
  final double animation;

  _CRTScanLinesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner les lignes de scan horizontales
    final lineSpacing = 2.0; // Espacement entre les lignes
    final lineOpacity = 0.15; // Opacité des lignes
    final paint = Paint()
      ..color = Colors.black.withOpacity(lineOpacity)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += lineSpacing * 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineSpacing),
        paint,
      );
    }

    // Effet de distorsion CRT (ligne qui se déplace verticalement)
    final scanLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final scanLineY = size.height * animation;
    canvas.drawRect(
      Rect.fromLTWH(0, scanLineY, size.width, 4.0),
      scanLinePaint,
    );

    // Effet de scintillement aléatoire
    if (math.Random().nextDouble() < 0.05) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(0.03),
      );
    }

    // Effet de distorsion au bord (effet de courbure d'écran CRT)
    final distortionPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.2),
        ],
        stops: const [0.85, 1.0],
        center: Alignment.center,
        radius: 1.0,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      distortionPaint,
    );
  }

  @override
  bool shouldRepaint(_CRTScanLinesPainter oldDelegate) {
    return oldDelegate.animation != animation;
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
    
    // Couleurs vives pour les bras (avec transparence pour l'effet brouillard)
    final List<Color> colors = [
      const Color.fromARGB(180, 244, 67, 54),
      const Color.fromARGB(180, 255, 153, 0),
      const Color.fromARGB(180, 255, 235, 59),
      const Color.fromARGB(180, 8, 85, 173),
      const Color.fromARGB(180, 33, 149, 243),
      const Color.fromARGB(180, 11, 192, 177),
      const Color.fromARGB(180, 218, 238, 39),
      const Color.fromARGB(180, 247, 42, 42),
    ];
    
    // Dessiner un fond sombre pour faire ressortir les couleurs
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.2),
    );
    
    // Paramètres pour la spirale
    const double turns = 3.0; // Nombre de tours de la spirale
    const double armWidth = 90.0; // Largeur de chaque bras (un peu plus large pour l'effet de fusion)
    
    // Dessiner d'abord les "ombres" des bras pour l'effet de brouillard
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
      
      // Dessiner l'ombre diffuse du bras (effet brouillard)
      final shadowPaint = Paint()
        ..color = colors[i % colors.length].withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = armWidth * 1.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
      
      canvas.drawPath(path, shadowPaint);
    }
    
    // Maintenant dessiner les bras principaux
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
        
        // Ajouter une légère variation pour un effet plus organique
        final variation = math.sin(t * 10 + animationValue * math.pi * 4) * 2.0;
        
        // Créer le chemin du bras
        if (firstPoint) {
          path.moveTo(x + variation, y + variation);
          firstPoint = false;
        } else {
          path.lineTo(x + variation, y + variation);
        }
      }
      
      // Dessiner le bras principal
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = armWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      
      canvas.drawPath(path, paint);
      
      // Ajouter un effet lumineux au centre du bras
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = armWidth * 0.4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      
      canvas.drawPath(path, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TornadoSpiralPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}