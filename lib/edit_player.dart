import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';
import 'package:badminton_player_system/player_form.dart';

class EditPlayer extends StatelessWidget {
  final PlayerItem player;
  final void Function(PlayerItem updatedPlayer) onUpdatePlayer;
  final void Function(PlayerItem playerToDelete) onDeletePlayer;

  const EditPlayer({
    super.key,
    required this.player,
    required this.onUpdatePlayer,
    required this.onDeletePlayer,
  });

  @override
  Widget build(BuildContext context) {
    return PlayerForm(
      title: 'Edit Player Profile',
      existingPlayer: player,
      onSavePlayer: onUpdatePlayer,
      onDeletePlayer: onDeletePlayer,
    );
  }
}