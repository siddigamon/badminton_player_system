import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';

class PlayerItemWidget extends StatelessWidget {
  const PlayerItemWidget(this.playerItem, {super.key});

  final PlayerItem playerItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playerItem.nickname,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              playerItem.fullName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(playerItem.fullLevelDescription),
                const Spacer(),
                Icon(levelIcons[playerItem.level]),
                const SizedBox(width: 5),
                Text(playerItem.formattedDateJoined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}