import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'models/board.dart';
import 'models/piece.dart';
import 'models/move.dart';
import 'models/game.dart';
import 'models/player.dart';
import 'widgets/chess_board.dart';
import 'widgets/chess_piece.dart';
import 'widgets/move_history.dart';
import 'widgets/player_info.dart';
import 'utils/constants.dart';
import 'utils/game_rules.dart';
import 'providers/game_provider.dart';
import 'services/move_validator.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Chess Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
