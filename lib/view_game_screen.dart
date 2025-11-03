import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/game_item.dart';
import 'package:badminton_player_system/model/player_items.dart';
import 'package:badminton_player_system/data/game_data.dart';

class ViewGameScreen extends StatefulWidget {
  final GameItem game;
  final List<PlayerItem> availablePlayers;
  final Function(GameItem) onGameUpdated;

  const ViewGameScreen({
    super.key,
    required this.game,
    required this.availablePlayers,
    required this.onGameUpdated,
  });

  @override
  State<ViewGameScreen> createState() => _ViewGameScreenState();
}

class _ViewGameScreenState extends State<ViewGameScreen> {
  late GameItem _game;
  List<PlayerItem> _queuedPlayers = [];

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    // Initialize with existing queued players if any
    _queuedPlayers = List.from(_game.queuedPlayers ?? []);
  }

  // Add player to queue
  void _addPlayerToQueue(PlayerItem player) {
    if (_queuedPlayers.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 players allowed for doubles match'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_queuedPlayers.any((p) => p.fullName == player.fullName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Player is already in the queue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _queuedPlayers.add(player);
      _updateGameWithQueue();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${player.nickname} added to queue'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Remove player from queue
  void _removePlayerFromQueue(PlayerItem player) {
    setState(() {
      _queuedPlayers.removeWhere((p) => p.fullName == player.fullName);
      _updateGameWithQueue();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${player.nickname} removed from queue'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Update game with current queue
  void _updateGameWithQueue() {
    _game = GameItem(
      id: _game.id,
      gameTitle: _game.gameTitle,
      courtName: _game.courtName,
      schedules: _game.schedules,
      courtRate: _game.courtRate,
      shuttleCockPrice: _game.shuttleCockPrice,
      divideCourtEqually: _game.divideCourtEqually,
      createdDate: _game.createdDate,
      numberOfPlayers: _queuedPlayers.length,
      queuedPlayers: _queuedPlayers,
    );
    
    // Update in GameData
    GameData.updateGame(_game);
    widget.onGameUpdated(_game);
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format time for display
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Show add player dialog
  void _showAddPlayerDialog() {
    final availableToAdd = widget.availablePlayers
        .where((player) => !_queuedPlayers.any((qp) => qp.fullName == player.fullName))
        .toList();

    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more players available to add'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Player to Queue'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableToAdd.length,
            itemBuilder: (context, index) {
              final player = availableToAdd[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text(
                    player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(player.fullName),
                subtitle: Text('${player.nickname} • ${player.level.name}'), // Use nickname and level enum
                onTap: () {
                  Navigator.of(ctx).pop();
                  _addPlayerToQueue(player);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _game.displayTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to Edit Game screen (future enhancement)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit game feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Edit Game',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Details Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_tennis, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Game Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    _buildDetailRow('Court Name', _game.courtName),
                    _buildDetailRow('Court Rate', '₱${_game.courtRate.toStringAsFixed(2)}/hour'),
                    _buildDetailRow('Shuttle Price', '₱${_game.shuttleCockPrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Cost Distribution', 
                        _game.divideCourtEqually ? 'Split equally' : 'Individual payment'),
                    _buildDetailRow('Total Cost', '₱${_game.totalCost.toStringAsFixed(2)}'),
                    
                    // ADD THIS COST BREAKDOWN SECTION:
                    const SizedBox(height: 16),
                    if (_game.divideCourtEqually && _game.actualPlayerCount > 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Cost Per Player',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₱${_game.costPerPlayer.toStringAsFixed(2)} each',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Total: ₱${_game.totalCost.toStringAsFixed(2)} ÷ ${_game.actualPlayerCount} players',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (!_game.divideCourtEqually) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Individual Payment',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Players pay based on their individual usage',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_game.divideCourtEqually && _game.actualPlayerCount == 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Waiting for Players',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cost will be split equally once players join (₱${_game.totalCost.toStringAsFixed(2)} total)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Player Queue Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people, color: Colors.green, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Player Queue',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _queuedPlayers.length == 4 
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_queuedPlayers.length}/4',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _queuedPlayers.length == 4 ? Colors.green : Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_queuedPlayers.length < 4)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _showAddPlayerDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Player'),
                          ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    if (_queuedPlayers.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No players in queue yet',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add players to start the doubles match',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _queuedPlayers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final player = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Card(
                              color: Colors.green.withOpacity(0.05),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  player.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${player.nickname} • ${player.level.name}'),
                                    if (_game.divideCourtEqually && _game.actualPlayerCount > 0)
                                      Text(
                                        'Owes: ₱${_game.costPerPlayer.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removePlayerFromQueue(player),
                                  tooltip: 'Remove from queue',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    if (_queuedPlayers.length == 4) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            const SizedBox(height: 8),
                            const Text(
                              'Queue Full - Ready to Play!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Doubles match ready with 4 players',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_queuedPlayers.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Payment Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_game.divideCourtEqually) ...[
                              Text(
                                'Each player pays: ₱${_game.costPerPlayer.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Total collected: ₱${(_game.costPerPlayer * _game.actualPlayerCount).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Individual payment method',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                'Total game cost: ₱${_game.totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}