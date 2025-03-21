# Chess Game Application

This is a Flutter mobile application for a chess game that allows two players to compete on the same device. The application implements the official rules of chess and provides an intuitive and responsive graphical interface.

## Features

- Two-player mode on the same device
- Intuitive user interface
- Official chess rules implemented
- Move history tracking
- Player information display
- Settings for game configuration

## Project Structure

```
chess_game
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── models                   # Contains classes for game logic
│   │   ├── board.dart           # Represents the chessboard
│   │   ├── piece.dart           # Defines chess pieces and their movements
│   │   ├── move.dart            # Represents a move made by a player
│   │   ├── game.dart            # Manages overall game state
│   │   └── player.dart          # Represents a player in the game
│   ├── widgets                  # UI components
│   │   ├── chess_board.dart     # Visual representation of the chessboard
│   │   ├── chess_piece.dart     # Visual representation of chess pieces
│   │   ├── move_history.dart     # Displays history of moves
│   │   └── player_info.dart     # Displays player information
│   ├── screens                  # Different screens of the app
│   │   ├── game_screen.dart     # Main screen for playing the game
│   │   ├── home_screen.dart     # Landing page of the app
│   │   └── settings_screen.dart  # Configuration settings
│   ├── utils                    # Utility functions and constants
│   │   ├── constants.dart       # Defines constants used throughout the app
│   │   └── game_rules.dart      # Implements chess rules
│   ├── providers                # State management
│   │   └── game_provider.dart   # Manages game state with ChangeNotifier
│   └── services                 # Services for game logic
│       └── move_validator.dart  # Validates moves according to chess rules
├── assets                       # Assets used in the application
│   └── images
│       └── pieces              # Images of chess pieces
├── pubspec.yaml                # Flutter project configuration
└── README.md                   # Project documentation
```

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd chess_game
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Usage

- Launch the app and navigate to the home screen.
- Start a new game to play chess against another player.
- Use the intuitive interface to move pieces according to the official chess rules.
- View the move history and player information during the game.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.