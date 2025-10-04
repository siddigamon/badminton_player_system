import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';
import 'package:intl/intl.dart';


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
  DateTime? _pickedDate;


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
      dateJoined: _pickedDate!,
    );

    widget.onAddPlayer(player);
    Navigator.pop(context);
  }

  void _showDatePopup() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow dates up to 1 year ago
      lastDate: DateTime.now(), // Can't join in the future
    );

    if (pickedDate != null) {
      setState(() {
        _pickedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMd();
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
              keyboardType: TextInputType.text,
              maxLength: 30,
            ),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              keyboardType: TextInputType.text,
              maxLength: 50,
            ),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
              maxLength: 15,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              keyboardType: TextInputType.text,
              maxLength: 100,
            ),
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(labelText: 'Remarks'),
              keyboardType: TextInputType.text,
              maxLength: 200,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                _showDatePopup();
              },
              label: Text(
                _pickedDate == null
                    ? "Please select join date"
                    : formatter.format(_pickedDate!),
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.calendar_today),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            //toDO: Badminton Level DropDown using RangeSlider
            DropdownButton<LevelStrength>(
              value: _selectedStrength,
              items: LevelStrength.values
                  .map(
                    (strength) => DropdownMenuItem(
                      value: strength,
                      child: Text(strength.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStrength = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _submitPlayerData();
                  },
                  child: const Text('Add Player'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
