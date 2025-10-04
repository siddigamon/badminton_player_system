import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';
import 'package:badminton_player_system/player_form.dart';

class NewPlayer extends StatelessWidget {
  final void Function(PlayerItem player) onAddPlayer;
  
  const NewPlayer({super.key, required this.onAddPlayer});

  @override
  Widget build(BuildContext context) {
    return PlayerForm(
      title: 'Add New Player',
      onSavePlayer: onAddPlayer,
    );
  }
}