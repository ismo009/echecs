import 'piece.dart';

class ChessBoard {
  // 8x8 board represented as a 2D array
  late List<List<ChessPiece?>> squares;

  ChessBoard() {
    // Initialize empty board
    squares = List.generate(
      8,
      (_) => List.generate(8, (_) => null),
    );
    setupInitialPosition();
  }

  // Set up the initial position of all pieces
  void setupInitialPosition() {
    // Clear the board first
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        squares[row][col] = null;
      }
    }

    // Set up pawns
    for (int i = 0; i < 8; i++) {
      squares[1][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      squares[6][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }

    // Set up rooks
    squares[0][0] = ChessPiece(type: PieceType.rook, color: PieceColor.black);
    squares[0][7] = ChessPiece(type: PieceType.rook, color: PieceColor.black);
    squares[7][0] = ChessPiece(type: PieceType.rook, color: PieceColor.white);
    squares[7][7] = ChessPiece(type: PieceType.rook, color: PieceColor.white);

    // Set up knights
    squares[0][1] = ChessPiece(type: PieceType.knight, color: PieceColor.black);
    squares[0][6] = ChessPiece(type: PieceType.knight, color: PieceColor.black);
    squares[7][1] = ChessPiece(type: PieceType.knight, color: PieceColor.white);
    squares[7][6] = ChessPiece(type: PieceType.knight, color: PieceColor.white);

    // Set up bishops
    squares[0][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    squares[0][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    squares[7][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.white);
    squares[7][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.white);

    // Set up queens
    squares[0][3] = ChessPiece(type: PieceType.queen, color: PieceColor.black);
    squares[7][3] = ChessPiece(type: PieceType.queen, color: PieceColor.white);

    // Set up kings
    squares[0][4] = ChessPiece(type: PieceType.king, color: PieceColor.black);
    squares[7][4] = ChessPiece(type: PieceType.king, color: PieceColor.white);
  }

  // Get piece at a specific position
  ChessPiece? getPieceAt(int row, int col) {
    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
      return squares[row][col];
    }
    return null;
  }

  // Move a piece from one position to another
  void movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = squares[fromRow][fromCol];
    if (piece != null) {
      piece.hasMoved = true;
      squares[toRow][toCol] = piece;
      squares[fromRow][fromCol] = null;
    }
  }

  // Make a deep copy of the board
  ChessBoard copy() {
    final boardCopy = ChessBoard();
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = squares[row][col];
        boardCopy.squares[row][col] = piece?.copy();
      }
    }
    return boardCopy;
  }
}