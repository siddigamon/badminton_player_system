import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badminton_player_system/model/game_item.dart';
import 'package:badminton_player_system/data/game_data.dart';

class EditGameScreen extends StatefulWidget {
  final GameItem game;
  final Function(GameItem) onGameUpdated;

  const EditGameScreen({
    super.key,
    required this.game,
    required this.onGameUpdated,
  });

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _gameTitleController;
  late TextEditingController _courtNameController;
  late TextEditingController _courtRateController;
  late TextEditingController _shuttleCockPriceController;
  
  late bool _divideCourtEqually;
  late bool _divideShuttleEqually;
  late List<GameSchedule> _schedules;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  @override
  void dispose() {
    _gameTitleController.dispose();
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttleCockPriceController.dispose();
    super.dispose();
  }

  void _loadGameData() {
    _gameTitleController = TextEditingController(text: widget.game.gameTitle);
    _courtNameController = TextEditingController(text: widget.game.courtName);
    _courtRateController = TextEditingController(text: widget.game.courtRate.toString());
    _shuttleCockPriceController = TextEditingController(text: widget.game.shuttleCockPrice.toString());
    _divideCourtEqually = widget.game.divideCourtEqually;
    _divideShuttleEqually = widget.game.divideShuttleEqually;
    _schedules = List.from(widget.game.schedules);
  }

  void _addSchedule() {
    showDialog(
      context: context,
      builder: (ctx) => _ScheduleDialog(
        onScheduleAdded: (schedule) {
          setState(() {
            _schedules.add(schedule);
          });
        },
      ),
    );
  }

  void _editSchedule(int index) {
    showDialog(
      context: context,
      builder: (ctx) => _ScheduleDialog(
        schedule: _schedules[index],
        onScheduleAdded: (schedule) {
          setState(() {
            _schedules[index] = schedule;
          });
        },
      ),
    );
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void _saveGame() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one schedule'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedGame = GameItem(
      id: widget.game.id,
      gameTitle: _gameTitleController.text.trim(),
      courtName: _courtNameController.text.trim(),
      schedules: List.from(_schedules),
      courtRate: double.parse(_courtRateController.text),
      shuttleCockPrice: double.parse(_shuttleCockPriceController.text),
      divideCourtEqually: _divideCourtEqually,
      divideShuttleEqually: _divideShuttleEqually,
      createdDate: widget.game.createdDate,
      numberOfPlayers: widget.game.numberOfPlayers,
      queuedPlayers: widget.game.queuedPlayers,
      shuttlePayerPlayerId: widget.game.shuttlePayerPlayerId, // ADD THIS LINE

    );

    GameData.updateGame(updatedGame);
    widget.onGameUpdated(updatedGame);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validatePrice(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid number';
    }

    if (price < 0) {
      return '$fieldName cannot be negative';
    }

    if (price > 9999.99) {
      return '$fieldName cannot exceed 9999.99';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveGame,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Title
                TextFormField(
                  controller: _gameTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Game Title (Optional)',
                    hintText: 'Leave blank to use scheduled date',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),

                // Court Name
                TextFormField(
                  controller: _courtNameController,
                  decoration: const InputDecoration(
                    labelText: 'Court Name *',
                    hintText: 'e.g., Badminton Court 1',
                    prefixIcon: Icon(Icons.sports_tennis),
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                  validator: (value) => _validateRequired(value, 'Court name'),
                ),
                const SizedBox(height: 16),

                // Court Rate
                TextFormField(
                  controller: _courtRateController,
                  decoration: const InputDecoration(
                    labelText: 'Court Rate (per hour) *',
                    hintText: '50.00',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'per hour',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) => _validatePrice(value, 'Court rate'),
                ),
                const SizedBox(height: 16),

                // Shuttle Price
                TextFormField(
                  controller: _shuttleCockPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Shuttle Cock Price *',
                    hintText: '15.00',
                    prefixIcon: Icon(Icons.sports),
                    suffixText: 'per game',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) => _validatePrice(value, 'Shuttle cock price'),
                ),
                const SizedBox(height: 24),

                // Cost Distribution
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cost Distribution',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        
                        CheckboxListTile(
                          title: const Text('Divide court cost equally among players'),
                          subtitle: Text(
                            _divideCourtEqually 
                                ? 'Court cost will be split equally among all players'
                                : 'Court cost charged individually',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: _divideCourtEqually,
                          activeColor: Colors.amber,
                          onChanged: (value) {
                            setState(() {
                              _divideCourtEqually = value ?? true;
                            });
                          },
                        ),
                        
                        CheckboxListTile(
                          title: const Text('Divide shuttle cost equally among players'),
                          subtitle: Text(
                            _divideShuttleEqually 
                                ? 'Shuttle cost will be split equally among all players'
                                : 'One player pays the full shuttle cost',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: _divideShuttleEqually,
                          activeColor: Colors.amber,
                          onChanged: (value) {
                            setState(() {
                              _divideShuttleEqually = value ?? true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Schedules Section
                const Text(
                  'Schedules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Court Schedules',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _addSchedule,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Schedule'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        if (_schedules.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No schedules added yet'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _schedules.length,
                            itemBuilder: (context, index) {
                              final schedule = _schedules[index];
                              return Card(
                                color: Colors.amber.withOpacity(0.1),
                                child: ListTile(
                                  leading: const Icon(Icons.schedule, color: Colors.amber),
                                  title: Text(schedule.displayText),
                                  subtitle: Text('Duration: ${schedule.durationInHours.toStringAsFixed(1)} hours'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editSchedule(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeSchedule(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _saveGame,
                        child: const Text('Update Game'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Schedule Dialog (reused from AddGameScreen)
class _ScheduleDialog extends StatefulWidget {
  final GameSchedule? schedule;
  final Function(GameSchedule) onScheduleAdded;

  const _ScheduleDialog({
    this.schedule,
    required this.onScheduleAdded,
  });

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courtNumberController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _courtNumberController.text = widget.schedule!.courtNumber;
      _selectedDate = widget.schedule!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.schedule!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.schedule!.endTime);
    }
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final schedule = GameSchedule(
      courtNumber: _courtNumberController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
    );

    widget.onScheduleAdded(schedule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule == null ? 'Add Schedule' : 'Edit Schedule'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _courtNumberController,
              decoration: const InputDecoration(
                labelText: 'Court Number *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            // Add date and time pickers here (simplified for brevity)
            Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            Text('Time: ${_startTime.format(context)} - ${_endTime.format(context)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: const Text('Save'),
        ),
      ],
    );
  }
}