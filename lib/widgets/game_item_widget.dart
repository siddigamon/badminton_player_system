import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/game_item.dart';

class GameItemWidget extends StatelessWidget {
  final GameItem game;

  const GameItemWidget(this.game, {super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getScheduleDisplay(GameItem game) {
    if (game.schedules.isEmpty) return 'No schedule';
    
    if (game.schedules.length == 1) {
      final schedule = game.schedules.first;
      return '${_formatDate(schedule.startTime)} at ${_formatTime(schedule.startTime)}';
    } else {
      final firstSchedule = game.schedules.first;
      return '${_formatDate(firstSchedule.startTime)} (+${game.schedules.length - 1} more)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Title and Court Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.displayTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Court: ${game.courtName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (game.divideCourtEqually && game.divideShuttleEqually && game.actualPlayerCount > 0) ...[
                      // Both court and shuttle divided equally
                      Text(
                        '₱${game.costPerPlayer.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'per player',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ] else if (game.divideCourtEqually && !game.divideShuttleEqually && game.actualPlayerCount > 0) ...[
                      // Court divided, shuttle individual
                      Text(
                        '₱${game.courtCostPerPlayer.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'per player',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '+₱${game.shuttleCockPrice.toStringAsFixed(2)} shuttle',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.orange,
                        ),
                      ),
                    ] else ...[
                      // Individual payment or no players
                      Text(
                        '₱${game.totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'total cost',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Schedule Info
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getScheduleDisplay(game),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (game.schedules.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${game.schedules.length} schedules',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Additional Info
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  game.divideCourtEqually 
                      ? Icons.people 
                      : Icons.person,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  game.divideCourtEqually 
                      ? 'Cost shared equally'
                      : 'Individual payment',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}