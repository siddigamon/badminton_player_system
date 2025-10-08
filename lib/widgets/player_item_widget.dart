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
        margin: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerItem.nickname,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
