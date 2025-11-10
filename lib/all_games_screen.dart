import 'package:badminton_player_system/model/player_items.dart';
import 'package:badminton_player_system/view_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/game_item.dart';
import 'package:badminton_player_system/widgets/game_item_widget.dart'; // Add this import


class AllGamesScreen extends StatefulWidget {
  final List<GameItem> games;
  final Function(GameItem) onGameDeleted;
  final VoidCallback onNavigateToAddGame;
  final List<PlayerItem> availablePlayers;

  const AllGamesScreen({
    super.key,
    required this.games,
    required this.onGameDeleted,
    required this.onNavigateToAddGame,
    required this.availablePlayers,
  });

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GameItem> get filteredGames {
    if (_searchController.text.isEmpty) {
      return widget.games;
    }
    final searchTerm = _searchController.text.toLowerCase();
    return widget.games.where((game) {
      final titleMatch = game.displayTitle.toLowerCase().contains(searchTerm);
      
      final dateString = game.schedules.isNotEmpty 
          ? '${game.schedules.first.startTime.day}/${game.schedules.first.startTime.month}/${game.schedules.first.startTime.year}'
          : '';
      final dateMatch = dateString.contains(searchTerm);
      
      final courtMatch = game.courtName.toLowerCase().contains(searchTerm);
      
      return titleMatch || dateMatch || courtMatch;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Games',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.onNavigateToAddGame,
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
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search games...',
                hintText: 'Enter game name or date',
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
                setState(() {});
              },
            ),
          ),
          
          // Games List
          filteredGames.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty 
                              ? Icons.sports_basketball 
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No games scheduled yet'
                              : 'No games found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        if (_searchController.text.isEmpty) ...[
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: widget.onNavigateToAddGame,
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Game'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredGames.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      return Dismissible(
                        key: Key(game.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                              title: const Text('Delete Game'),
                              content: Text('Are you sure you want to delete "${game.displayTitle}"?'),
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
                          widget.onGameDeleted(game);
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewGameScreen(
                                  game: game,
                                  availablePlayers: widget.availablePlayers, 
                                  onGameUpdated: (updatedGame) {
                                    widget.onGameDeleted(game); 
                                    setState(() {
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: GameItemWidget(game),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      
      // Floating Action Button for Add Game
      // floatingActionButton: FloatingActionButton(
      //   onPressed: widget.onNavigateToAddGame,
      //   backgroundColor: Colors.amber,
      //   foregroundColor: Colors.white,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}