import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';

class PlayerItemWidget extends StatelessWidget {
  const PlayerItemWidget(this.playerItem, {super.key});

  final PlayerItem playerItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerItem.nickname,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                  '${playerItem.fullName} • ${playerItem.rangeDescription}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       playerItem.rangeDescription,
              //       style: const TextStyle(
              //         fontWeight: FontWeight.w500,
              //         color: Colors.blue,
              //       ),
              //     ),
              //     // const Spacer(),
              //     // Icon(levelIcons[playerItem.level]),
              //     // const SizedBox(width: 5),
              //     // Text(playerItem.formattedDateJoined),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}