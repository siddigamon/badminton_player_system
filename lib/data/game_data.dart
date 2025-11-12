import '../model/game_item.dart';

class GameData {
  static List<GameItem> gameItems = [
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
      divideShuttleEqually: true,
      shuttlePayerPlayerId: null,
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
      divideShuttleEqually: true,
      shuttlePayerPlayerId: null,
    ),
    GameItem(
      id: '3',
      gameTitle: '', 
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
      divideShuttleEqually: false,
      shuttlePayerPlayerId: null,
    ),
  ];

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

  static int get totalGames => gameItems.length;
}