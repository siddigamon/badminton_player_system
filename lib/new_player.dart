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

  RangeValues _levelRange = const RangeValues(0,2);


  // BadmintonLevel _selectedLevel = BadmintonLevel.beginners;
  // LevelStrength _selectedStrength = LevelStrength.mid;
  // DateTime? _pickedDate;


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

   (BadmintonLevel, LevelStrength) _getFromSliderValue(double value) {
    final levelIndex = (value / 3).floor();
    final strengthIndex = (value % 3).floor();
    
    return (
      BadmintonLevel.values[levelIndex.clamp(0, BadmintonLevel.values.length - 1)],
      LevelStrength.values[strengthIndex.clamp(0, LevelStrength.values.length - 1)]
    );
  }

  double _getSliderValue(BadmintonLevel level, LevelStrength strength) {
    final levelIndex = BadmintonLevel.values.indexOf(level);
    final strengthIndex = LevelStrength.values.indexOf(strength);
    return (levelIndex * 3 + strengthIndex).toDouble();
  }

  String _getDisplayText(double value) {
    final (level, strength) = _getFromSliderValue(value);
    final levelText = level.name.toUpperCase().replaceAll('LEVEL', 'Level ');
    final strengthText = strength.name.toUpperCase();
    return '$levelText - $strengthText';
  }

  void _submitPlayerData() {
    // Add validation logic here

    final (startLevel, startStrength) = _getFromSliderValue(_levelRange.start);
    final (endLevel, endStrength) = _getFromSliderValue(_levelRange.end);

    final midpoint = (_levelRange.start + _levelRange.end) / 2;
    final (selectedLevel, selectedStrength) = _getFromSliderValue(midpoint);

    final player = PlayerItem(
      nickname: _nicknameController.text,
      fullName: _fullNameController.text,
      contactNumber: _contactController.text,
      email: _emailController.text,
      address: _addressController.text,
      remarks: _remarksController.text,
      level: selectedLevel,
      strength: selectedStrength,
      dateJoined: DateTime.now(),
      rangeStartLevel: startLevel,
      rangeStartStrength: startStrength,
      rangeEndLevel: endLevel,
      rangeEndStrength: endStrength,
    );

    widget.onAddPlayer(player);
    Navigator.pop(context);
  }

  // void _showDatePopup() async {
  //   final pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow dates up to 1 year ago
  //     lastDate: DateTime.now(), // Can't join in the future
  //   );

  //   if (pickedDate != null) {
  //     setState(() {
  //       _pickedDate = pickedDate;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final formatter = DateFormat.yMd();
    final maxValue = (BadmintonLevel.values.length * LevelStrength.values.length - 1).toDouble();

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
            // ElevatedButton.icon(
            //   onPressed: () {
            //     _showDatePopup();
            //   },
            //   label: Text(
            //     _pickedDate == null
            //         ? "Please select join date"
            //         : formatter.format(_pickedDate!),
            //     textAlign: TextAlign.left,
            //     style: const TextStyle(color: Colors.white),
            //   ),
            //   icon: const Icon(Icons.calendar_today),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     foregroundColor: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(2.0),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),
            //toDO: Badminton Level DropDown using RangeSlider
            const Text(
              'Badminton Level Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: ${_getDisplayText(_levelRange.start)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'To: ${_getDisplayText(_levelRange.end)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
             RangeSlider(
              values: _levelRange,
              min: 0,
              max: maxValue,
              divisions: maxValue.toInt(),
              activeColor: Colors.amber,
              inactiveColor: Colors.amber.withOpacity(0.3),
              labels: RangeLabels(
                _getDisplayText(_levelRange.start),
                _getDisplayText(_levelRange.end),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _levelRange = values;
                });
              },
            ),
             const Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('Beginners', style: TextStyle(fontSize: 12)),
                   Text('Intermediate', style: TextStyle(fontSize: 12)),
                   Text('Level G', style: TextStyle(fontSize: 12)),
                   Text('Level F', style: TextStyle(fontSize: 12)),
                   Text('Level E', style: TextStyle(fontSize: 12)),
                   Text('Level D', style: TextStyle(fontSize: 12)),
                   Text('Open', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
