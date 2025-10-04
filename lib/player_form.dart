import 'package:flutter/material.dart';
import 'package:badminton_player_system/model/player_items.dart';

class PlayerForm extends StatefulWidget {
  final PlayerItem? existingPlayer; // null for new, non-null for edit
  final void Function(PlayerItem player) onSavePlayer;
  final void Function(PlayerItem player)? onDeletePlayer; // only for edit mode
  final String title;

  const PlayerForm({
    super.key,
    this.existingPlayer,
    required this.onSavePlayer,
    this.onDeletePlayer,
    required this.title,
  });

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _remarksController;

  late RangeValues _levelRange;

  bool get isEditMode => widget.existingPlayer != null;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill controllers if editing
    final player = widget.existingPlayer;
    _nicknameController = TextEditingController(text: player?.nickname ?? '');
    _fullNameController = TextEditingController(text: player?.fullName ?? '');
    _contactController = TextEditingController(text: player?.contactNumber ?? '');
    _emailController = TextEditingController(text: player?.email ?? '');
    _addressController = TextEditingController(text: player?.address ?? '');
    _remarksController = TextEditingController(text: player?.remarks ?? '');

    // Set slider range
    if (player != null) {
      final startValue = _getSliderValue(player.rangeStartLevel, player.rangeStartStrength);
      final endValue = _getSliderValue(player.rangeEndLevel, player.rangeEndStrength);
      _levelRange = RangeValues(startValue, endValue);
    } else {
      _levelRange = const RangeValues(0, 2);
    }
  }

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
      dateJoined: widget.existingPlayer?.dateJoined ?? DateTime.now(), // Keep original or set new
      rangeStartLevel: startLevel,
      rangeStartStrength: startStrength,
      rangeEndLevel: endLevel,
      rangeEndStrength: endStrength,
    );

    widget.onSavePlayer(player);
    Navigator.pop(context);
  }

  void _deletePlayer() async {
    if (widget.onDeletePlayer != null && widget.existingPlayer != null) {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Player'),
          content: Text('Are you sure you want to permanently delete ${widget.existingPlayer!.nickname}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        widget.onDeletePlayer!(widget.existingPlayer!);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = (BadmintonLevel.values.length * LevelStrength.values.length - 1).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            
            // Badminton Level Range Slider
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
            
            // Action buttons - conditional based on mode
            if (isEditMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submitPlayerData,
                    child: const Text('Update Player'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  if (widget.onDeletePlayer != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _deletePlayer,
                      child: const Text('Delete'),
                    ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submitPlayerData,
                    child: const Text('Add Player'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
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