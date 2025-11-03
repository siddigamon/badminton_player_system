import '../model/game_item.dart';

class GameData {
  // Static list of games (following same pattern as your players)
  static List<GameItem> gameItems = [
    // Sample games for demo
    GameItem(
      id: '1',
      gameTitle: 'Weekend Tournament',
      courtName: 'Badminton Court 1',
      schedules: [
        GameSchedule(
          courtNumber: '1',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 21)),
        ),
      ],
      courtRate: 50.0,
      shuttleCockPrice: 15.0,
      divideCourtEqually: true,
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
      numberOfPlayers: 4,
    ),
    GameItem(
      id: '2',
      gameTitle: 'Practice Session',
      courtName: 'Badminton Court 2',
      schedules: [
        GameSchedule(
          courtNumber: '2',
          startTime: DateTime.now().add(const Duration(days: 2, hours: 19)),
          endTime: DateTime.now().add(const Duration(days: 2, hours: 22)),
        ),
      ],
      courtRate: 50.0,
      shuttleCockPrice: 15.0,
      divideCourtEqually: true,
      createdDate: DateTime.now().subtract(const Duration(hours: 12)),
      numberOfPlayers: 2,
    ),
    GameItem(
      id: '3',
      gameTitle: '', // Empty title - will use date as title
      courtName: 'Badminton Court 1',
      schedules: [
        GameSchedule(
          courtNumber: '1',
          startTime: DateTime.now().add(const Duration(days: 3, hours: 20)),
          endTime: DateTime.now().add(const Duration(days: 3, hours: 23)),
        ),
      ],
      courtRate: 60.0,
      shuttleCockPrice: 20.0,
      divideCourtEqually: false,
      createdDate: DateTime.now().subtract(const Duration(hours: 6)),
      numberOfPlayers: 3,
    ),
  ];

  // Helper methods to manage the games list
  static void addGame(GameItem game) {
    gameItems.add(game);
  }

  static void removeGame(GameItem game) {
    gameItems.remove(game);
  }

  static void updateGame(GameItem updatedGame) {
    final index = gameItems.indexWhere((g) => g.id == updatedGame.id);
    if (index != -1) {
      gameItems[index] = updatedGame;
    }
  }

  // Get game by ID
  static GameItem? getGameById(String id) {
    try {
      return gameItems.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get total number of games
  static int get totalGames => gameItems.length;
}