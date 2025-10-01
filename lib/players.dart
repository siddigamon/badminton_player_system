import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';
import 'package:badminton_player_system/new_player.dart';

class Players extends StatefulWidget {
  const Players({super.key});

  @override
  State<Players> createState() => _PlayersState();
}

class _PlayersState extends State<Players> {
  List<PlayerItem> playerItems = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton Players'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddPlayer();
            },
            icon: const Icon(
              Icons.add,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('List of Badminton Players will be shown here.'),
      ),
    );
  }
}
