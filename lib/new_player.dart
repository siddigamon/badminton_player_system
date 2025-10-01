import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';

class NewPlayer extends StatefulWidget {
  final void Function(PlayerItem player) onAddPlayer;
  const NewPlayer({super.key, required this.onAddPlayer});

  @override
  State<NewPlayer> createState() => _NewPlayerState();
}

class _NewPlayerState extends State<NewPlayer> {
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarksController = TextEditingController();

  BadmintonLevel _selectedLevel = BadmintonLevel.beginners;
  LevelStrength _selectedStrength = LevelStrength.mid;

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitPlayerData() {
    // Add validation logic here
    final player = PlayerItem(
      nickname: _nicknameController.text,
      fullName: _fullNameController.text,
      contactNumber: _contactController.text,
      email: _emailController.text,
      address: _addressController.text,
      remarks: _remarksController.text,
      level: _selectedLevel,
      strength: _selectedStrength,
      dateJoined: DateTime.now(),
    );

    widget.onAddPlayer(player);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Player'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
            ),
            // Add other form fields...
            // Add level slider...
            // Add action buttons...
          ],
        ),
      ),
    );
  }
}
