import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';
import 'package:badminton_player_system/new_player.dart';
import 'package:badminton_player_system/widgets/player_item_widget.dart';
import 'package:badminton_player_system/edit_player.dart';
import 'package:badminton_player_system/add_game_screen.dart';
import 'package:badminton_player_system/all_games_screen.dart';
import 'package:badminton_player_system/user_settings_screen.dart';
import 'package:badminton_player_system/data/game_data.dart'; 
import 'package:badminton_player_system/model/game_item.dart'; 



class Players extends StatefulWidget {
  const Players({super.key});

  @override
  State<Players> createState() => _PlayersState();
}

class _PlayersState extends State<Players> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0; // 0 = Players (default), 1 = Add Game, 2 = All Games, 3 = Settings
  
  List<PlayerItem> playerItems = [
    PlayerItem(
      nickname: 'AcePlayer',
      fullName: 'John Smith',
      contactNumber: '+1234567890',
      email: 'john.smith@email.com',
      address: '123 Main Street, City',
      remarks: 'Great player, very competitive',
      level: BadmintonLevel.levelE,
      strength: LevelStrength.strong,
      dateJoined: DateTime.now().subtract(const Duration(days: 30)),
      rangeStartLevel: BadmintonLevel.levelF,
      rangeStartStrength: LevelStrength.mid,
      rangeEndLevel: BadmintonLevel.levelE,
      rangeEndStrength: LevelStrength.strong,
    ),
    PlayerItem(
      nickname: 'Rookie',
      fullName: 'Jane Doe',
      contactNumber: '+0987654321',
      email: 'jane.doe@email.com',
      address: '456 Oak Avenue, Town',
      remarks: 'New player, eager to learn',
      level: BadmintonLevel.beginners,
      strength: LevelStrength.weak,
      dateJoined: DateTime.now().subtract(const Duration(days: 7)),
      rangeStartLevel: BadmintonLevel.beginners,
      rangeStartStrength: LevelStrength.weak,
      rangeEndLevel: BadmintonLevel.intermediate,
      rangeEndStrength: LevelStrength.mid,
    ),
    PlayerItem(
      nickname: 'ProShuttle',
      fullName: 'Mike Johnson',
      contactNumber: '+1122334455',
      email: 'mike.johnson@email.com',
      address: '789 Pine Road, Village',
      remarks: 'Experienced player, good coach',
      level: BadmintonLevel.levelD,
      strength: LevelStrength.strong,
      dateJoined: DateTime.now().subtract(const Duration(days: 60)),
      rangeStartLevel: BadmintonLevel.levelE,
      rangeStartStrength: LevelStrength.mid,
      rangeEndLevel: BadmintonLevel.levelD,
      rangeEndStrength: LevelStrength.strong,
    ),
  ];

  List<PlayerItem> get filteredPlayers {
    if (_searchController.text.isEmpty) {
      return playerItems;
    }
    final searchTerm = _searchController.text.toLowerCase();
    return playerItems.where((player) {
      return player.nickname.toLowerCase().contains(searchTerm) ||
             player.fullName.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddPlayer() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewPlayer(onAddPlayer: _addPlayerItem),
    );
  }

  void _addPlayerItem(PlayerItem player) {
    setState(() {
      playerItems.add(player);
    });
  }

  void _editPlayer(PlayerItem player) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => EditPlayer(
        player: player,
        onUpdatePlayer: _updatePlayerItem,
        onDeletePlayer: _deletePlayerItem,
      ),
    );
  }

  void _updatePlayerItem(PlayerItem updatedPlayer) {
    setState(() {
      final index = playerItems.indexWhere((p) => p.dateJoined == updatedPlayer.dateJoined);
      if (index != -1) {
        playerItems[index] = updatedPlayer;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updatedPlayer.nickname} updated successfully')),
    );
  }

  void _deletePlayerItem(PlayerItem playerToDelete) {
    setState(() {
      playerItems.remove(playerToDelete);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${playerToDelete.nickname} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              playerItems.add(playerToDelete);
            });
          },
        ),
      ),
    );
  }

  // NEW: Game management methods (using GameData)
  void _addGameItem(GameItem game) {
    setState(() {
      GameData.addGame(game);
    });
  }

  void _deleteGameItem(GameItem gameToDelete) {
    setState(() {
      GameData.removeGame(gameToDelete);
    });
  }

  void _navigateToAddGame() {
    setState(() {
      _selectedIndex = 1; // Add Game tab
    });
  }

  Widget _buildPlayersScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Players',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                _showAddPlayer();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.add,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search players...',
                hintText: 'Enter nickname or full name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Refresh the list when search text changes
              },
            ),
          ),
          // Player List
          filteredPlayers.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty 
                              ? Icons.group_add 
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No players added yet'
                              : 'No players found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    itemCount: filteredPlayers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 5.0), 
                    itemBuilder: (context, index) {
                      final player = filteredPlayers[index];
                      return Dismissible(
                        key: Key(player.nickname + player.dateJoined.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Player'),
                              content: Text('Deleting ${player.nickname}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          final deletedPlayer = player;
                          setState(() {
                            playerItems.remove(player);
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${deletedPlayer.nickname} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  setState(() {
                                    playerItems.add(deletedPlayer);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => _editPlayer(player),
                          child: PlayerItemWidget(player),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the screens for navigation
    final List<Widget> screens = [
      _buildPlayersScreen(),      // Index 0 - Players screen (default)
      AddGameScreen(onGameAdded: _addGameItem),      // Index 1 - Add Game screen
      AllGamesScreen(                           // Index 2 - All Games screen (with parameters)
      games: GameData.gameItems,
      onGameDeleted: _deleteGameItem,
      onNavigateToAddGame: _navigateToAddGame,
      availablePlayers: playerItems,
    ),     // Index 2 - All Games screen
      const UserSettingsScreen(), // Index 3 - Settings screen
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}