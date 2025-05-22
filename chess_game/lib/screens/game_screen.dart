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

  static final GlobalKey chessBoardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          //Spirale de l'echec
          const ColorfulSpiralBackground(),

          //Contenu du jeux
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Titrre
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Container(
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
                          color: Color.fromARGB(255, 36, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Timer noir
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
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

              // Plateau d'échecs
              Center( 
                child: SizedBox(
                  key: chessBoardKey, // Ajoutez la clé ici
                  width: screenWidth * 0.9,
                  height: screenWidth * 1.1,
                  child: ChessBoardWidget(
                    board: Provider.of<GameProvider>(context).game.board,
                    onPieceMoved: (fromRow, fromCol, toRow, toCol) {
                      // Obtenir l'instance du GameProvider
                      final gameProvider = Provider.of<GameProvider>(context, listen: false);
                      
                      if (gameProvider.game.board.getPieceAt(toRow, toCol) != null) { //Cas capture
                        gameProvider.makeMove(fromRow, fromCol, toRow, toCol);
                        if(gameProvider.game.currentTurn == PieceColor.white) {
                          playMoveAnimation(fromRow, fromCol, toRow, toCol, context, "captureB");
                        } else {
                          playMoveAnimation(fromRow, fromCol, toRow, toCol, context, "captureW");
                        }
                      }
                      else { //Cas move
                        gameProvider.makeMove(fromRow, fromCol, toRow, toCol);
                        playMoveAnimation(fromRow, fromCol, toRow, toCol, context, "move");
                      }
                    },
                  ),
                ),
              ),
              

              // Timer blanc
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
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
        ],
      ),
    );
  }
}

//Pour l'animation de deplacement
void playMoveAnimation(int fromRow, int fromCol, int toRow, int toCol, BuildContext context, String moveType) {  
  // Créer un overlay pour l'animation
  final overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;
  
  // Séquence d'images pour l'animation selon le type de mouvement
  List<String> animationFrames;
  int frameDuration;
  
  switch (moveType) {
    case 'captureW':
      animationFrames = [
        'assets/images/animations/captureW0.png',
        'assets/images/animations/captureW1.png',
        'assets/images/animations/captureW2.png',
        'assets/images/animations/captureW3.png',
        'assets/images/animations/captureW4.png',
        'assets/images/animations/captureW5.png',
        'assets/images/animations/captureW6.png',
        'assets/images/animations/captureW7.png',
      ];
      frameDuration = 90;
      break;
    case 'captureB':
      animationFrames = [
        'assets/images/animations/captureB0.png',
        'assets/images/animations/captureB1.png',
        'assets/images/animations/captureB2.png',
        'assets/images/animations/captureB3.png',
        'assets/images/animations/captureB4.png',
        'assets/images/animations/captureB5.png',
        'assets/images/animations/captureB6.png',
        'assets/images/animations/captureB7.png',
      ];
      frameDuration = 90;
      break;
    case 'promotion':
      animationFrames = [
        'assets/images/animations/promotion0.png',
        'assets/images/animations/promotion1.png',
        'assets/images/animations/promotion2.png',
        'assets/images/animations/promotion3.png',
      ];
      frameDuration = 150;
      break;
    case 'move':
    default:
      animationFrames = [
        'assets/images/animations/deplacement0.png',
        'assets/images/animations/deplacement1.png',
        'assets/images/animations/deplacement2.png',
        'assets/images/animations/deplacement3.png',
      ];
      frameDuration = 100;
      break;
  }
  
  int currentFrame = 0;
  
  // Calculer la position du plateau d'échecs sur l'écran avec correction
  // Augmenter la valeur de boardTopOffset pour déplacer l'animation vers le bas
  final RenderBox? boardBox = GameScreen.chessBoardKey.currentContext?.findRenderObject() as RenderBox?;
  final Offset? boardPosition = boardBox?.localToGlobal(Offset.zero);
  
  final screenWidth = MediaQuery.of(context).size.width;
  final boardSize = screenWidth * 0.9;
  final cellSize = boardSize / 8;
  
  // Position absolue sur l'écran
  final boardLeftOffset = (screenWidth - boardSize) / 2;
  
  overlayEntry = OverlayEntry(
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Positions dans le système de coordonnées du plateau d'échecs
          final toXPos = toCol * cellSize;
          final toYPos = toRow * cellSize;
          
          return Positioned(
            left: boardLeftOffset + toXPos,
            top: (boardPosition?.dy ?? 0) + toYPos + cellSize,
            width: cellSize,
            height: cellSize,
            child: Image.asset(
              animationFrames[currentFrame],
              fit: BoxFit.contain,
            ),
          );
        },
      );
    },
  );
  
  // Ajouter l'overlay à l'écran
  overlayState.insert(overlayEntry);
  
  void nextFrame() {
    if (currentFrame < animationFrames.length - 1) {
      currentFrame++;
      overlayEntry.markNeedsBuild();
      Future.delayed(Duration(milliseconds: frameDuration), nextFrame);
    } else {
      // Animation terminée, supprimer l'overlay
      overlayEntry.remove();
    }
  }
  
  // Démarrer l'animation
  Future.delayed(Duration(milliseconds: frameDuration), nextFrame);
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
      duration: const Duration(seconds: 30), // Slower animation
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
    
    // Reduced number of arms for better performance
    const int armCount = 5;
    
    // Couleurs vives pour les bras (avec transparence pour l'effet brouillard)
    final List<Color> colors = [
      const Color.fromARGB(180, 244, 67, 54),
      const Color.fromARGB(180, 255, 153, 0),
      const Color.fromARGB(180, 255, 235, 59),
      const Color.fromARGB(180, 33, 149, 243),
      const Color.fromARGB(180, 11, 192, 177),
    ];
    
    // Dessiner un fond sombre pour faire ressortir les couleurs
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.2),
    );
    
    // Paramètres pour la spirale
    const double turns = 2.0; // Reduced number of turns
    const double armWidth = 70.0; // Slightly thinner arms
    
    // Use a lower resolution for the paths (increase step size)
    const double stepSize = 0.02; // Increased from 0.005 (4x faster)
    
    // Cache the sine calculations for variations
    final variations = List.generate(
      (1.0 / stepSize).ceil() + 1,
      (index) => math.sin(index * stepSize * 10 + animationValue * math.pi * 4) * 2.0
    );
    
    // Draw the spiral arms using a simplified approach
    for (int i = 0; i < armCount; i++) {
      final armPhase = i * (math.pi * 2 / armCount);
      final rotationOffset = animationValue * math.pi * 2;
      final color = colors[i % colors.length];
      
      // Create one path for both shadow and main arm to reduce drawing operations
      final path = Path();
      bool firstPoint = true;
      
      // Points pour former le chemin du bras (with larger step size)
      int variationIndex = 0;
      for (double t = 0.0; t <= 1.0; t += stepSize) {
        // Formule de la spirale avec rotation animée
        final angle = armPhase + turns * t * math.pi * 2 + rotationOffset;
        final radius = t * maxRadius;
        
        // Position sur la spirale
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        // Use cached variation
        final variation = variations[variationIndex];
        variationIndex = (variationIndex + 1) % variations.length;
        
        // Créer le chemin du bras
        if (firstPoint) {
          path.moveTo(x + variation, y + variation);
          firstPoint = false;
        } else {
          path.lineTo(x + variation, y + variation);
        }
      }
      
      // Dessiner l'ombre diffuse du bras (effet brouillard)
      // Use a simpler blur with lower quality but better performance
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = armWidth * 1.2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0); // Reduced blur radius
      
      canvas.drawPath(path, shadowPaint);
      
      // Dessiner le bras principal with simpler styling
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = armWidth * 0.7 // Thinner for performance
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, paint);
      
      // Skip the highlight effect for better performance
      // The shadow and main color still give a nice effect
    }
  }

  @override
  bool shouldRepaint(covariant _TornadoSpiralPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}