# Application de Jeu d'Échecs

Il s'agit d'une application mobile Flutter pour un jeu d'échecs qui permet à deux joueurs de s'affronter sur le même appareil. L'application implémente les règles officielles des échecs et propose une interface graphique intuitive et réactive.

## Fonctionnalités

- Mode deux joueurs sur le même appareil
- Interface utilisateur intuitive
- Règles officielles des échecs implémentées
- Suivi de l'historique des mouvements
- Affichage des informations des joueurs
- Paramètres pour la configuration du jeu

## Structure du Projet

```
chess_game
├── lib
│   ├── main.dart                # Point d'entrée de l'application
│   ├── models                   # Contient les classes pour la logique du jeu
│   │   ├── board.dart           # Représente l'échiquier
│   │   ├── piece.dart           # Définit les pièces d'échecs et leurs mouvements
│   │   ├── move.dart            # Représente un mouvement fait par un joueur
│   │   ├── game.dart            # Gère l'état global du jeu
│   │   └── player.dart          # Représente un joueur dans le jeu
│   ├── widgets                  # Composants UI
│   │   ├── chess_board.dart     # Représentation visuelle de l'échiquier
│   │   ├── chess_piece.dart     # Représentation visuelle des pièces d'échecs
│   │   ├── move_history.dart    # Affiche l'historique des mouvements
│   │   └── player_info.dart     # Affiche les informations du joueur
│   ├── screens                  # Différents écrans de l'application
│   │   ├── game_screen.dart     # Écran principal pour jouer au jeu
│   │   ├── home_screen.dart     # Page d'accueil de l'application
│   │   └── settings_screen.dart # Paramètres de configuration
│   ├── utils                    # Fonctions utilitaires et constantes
│   │   ├── constants.dart       # Définit les constantes utilisées dans l'application
│   │   └── game_rules.dart      # Implémente les règles des échecs
│   ├── providers                # Gestion de l'état
│   │   └── game_provider.dart   # Gère l'état du jeu avec ChangeNotifier
│   └── services                 # Services pour la logique du jeu
│       └── move_validator.dart  # Valide les mouvements selon les règles des échecs
├── assets                       # Ressources utilisées dans l'application
│   └── images
│       └── pieces              # Images des pièces d'échecs
├── pubspec.yaml                # Configuration du projet Flutter
└── README.md                   # Documentation du projet
```

## Instructions d'Installation

1. Cloner le dépôt:
   ```
   git clone <url-du-dépôt>
   ```

2. Naviguer vers le répertoire du projet:
   ```
   cd chess_game
   ```

3. Installer les dépendances:
   ```
   flutter pub get
   ```

4. Lancer l'application:
   ```
   flutter run
   ```

## Utilisation

- Lancez l'application et naviguez vers l'écran d'accueil.
- Commencez une nouvelle partie pour jouer aux échecs contre un autre joueur.
- Utilisez l'interface intuitive pour déplacer les pièces selon les règles officielles des échecs.
- Consultez l'historique des mouvements et les informations des joueurs pendant la partie.

## Contribuer

Les contributions sont les bienvenues! N'hésitez pas à soumettre une pull request ou à ouvrir une issue pour toute suggestion ou amélioration.