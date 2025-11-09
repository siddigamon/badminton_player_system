import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badminton_player_system/model/game_item.dart';
import 'package:badminton_player_system/model/user_settings.dart';

class AddGameScreen extends StatefulWidget {
  final Function(GameItem)? onGameAdded;
  const AddGameScreen({super.key, this.onGameAdded});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _gameTitleController = TextEditingController();
  final TextEditingController _courtNameController = TextEditingController();
  final TextEditingController _courtRateController = TextEditingController();
  final TextEditingController _shuttleCockPriceController = TextEditingController();
  
  bool _divideCourtEqually = true;
  bool _divideShuttleEqually = true;

  List<GameSchedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadDefaultSettings();
  }

  @override
  void dispose() {
    _gameTitleController.dispose();
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttleCockPriceController.dispose();
    super.dispose();
  }

  void _loadDefaultSettings() {
    _courtNameController.text = UserSettings.defaultCourtName;
    _courtRateController.text = UserSettings.defaultCourtRate.toString();
    _shuttleCockPriceController.text = UserSettings.defaultShuttleCockPrice.toString();
    _divideCourtEqually = UserSettings.defaultDivideCourtEqually;
    _divideShuttleEqually = UserSettings.defaultDivideShuttleEqually;
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

    final game = GameItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameTitle: _gameTitleController.text.trim(),
      courtName: _courtNameController.text.trim(),
      schedules: List.from(_schedules),
      courtRate: double.parse(_courtRateController.text),
      shuttleCockPrice: double.parse(_shuttleCockPriceController.text),
      divideCourtEqually: _divideCourtEqually,
      createdDate: DateTime.now(), 
      divideShuttleEqually: _divideShuttleEqually,
    );

    print('Game saved: ${game.displayTitle}');
    print('Court: ${game.courtName}');
    print('Schedules: ${game.schedules.length}');
    print('Court Rate: ${game.courtRate}');
    print('Shuttle Price: ${game.shuttleCockPrice}');
    print('Divide Equally: ${game.divideCourtEqually}');
    print('Divide Shuttle Equally: ${game.divideShuttleEqually}');

    if (widget.onGameAdded != null) {
      widget.onGameAdded!(game);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    _clearForm();
  }

  
void _cancelGame() {
  if (_hasUnsavedChanges()) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _clearForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changes discarded'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form cleared'),
        backgroundColor: Colors.grey,
      ),
    );
    _clearForm();
  }
}

  bool _hasUnsavedChanges() {
    return _gameTitleController.text.isNotEmpty ||
           _courtNameController.text != UserSettings.defaultCourtName ||
           _courtRateController.text != UserSettings.defaultCourtRate.toString() ||
           _shuttleCockPriceController.text != UserSettings.defaultShuttleCockPrice.toString() ||
           _divideCourtEqually != UserSettings.defaultDivideCourtEqually ||
           _schedules.isNotEmpty;
  }

  void _clearForm() {
    _gameTitleController.clear();
    _loadDefaultSettings();
    setState(() {
      _schedules.clear();
    });
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

  // Widget _buildCostPreview() {
  //   final courtRate = double.tryParse(_courtRateController.text) ?? 0.0;
  //   final shuttlePrice = double.tryParse(_shuttleCockPriceController.text) ?? 0.0;
  //   final estimatedHours = 2.0; // Assume 2 hours for preview
  //   final totalCourtCost = courtRate * estimatedHours;
  //   final totalCost = totalCourtCost + shuttlePrice;
    
  //   if (_divideCourtEqually && _divideShuttleEqually) {
  //     final perPlayer = totalCost / 4;
  //     return Text('Each player pays: ₱${perPlayer.toStringAsFixed(2)}');
  //   } else if (_divideCourtEqually && !_divideShuttleEqually) {
  //     final courtPerPlayer = totalCourtCost / 4;
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('Each player pays: ₱${courtPerPlayer.toStringAsFixed(2)} (court)'),
  //         Text('One player pays: ₱${shuttlePrice.toStringAsFixed(2)} (shuttle)'),
  //       ],
  //     );
  //   } else if (!_divideCourtEqually && _divideShuttleEqually) {
  //     final shuttlePerPlayer = shuttlePrice / 4;
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('Court cost: Individual payment'),
  //         Text('Each player pays: ₱${shuttlePerPlayer.toStringAsFixed(2)} (shuttle)'),
  //       ],
  //     );
  //   } else {
  //     return const Text('All costs: Individual payment');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.clear, color: Colors.white),
        //     onPressed: _clearForm,
        //     tooltip: 'Clear Form',
        //   ),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                const Text(
                  'Game Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a new badminton game',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Game Title (Optional)
                TextFormField(
                  controller: _gameTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Game Title (Optional)',
                    hintText: 'Leave blank to use scheduled date',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  keyboardType: TextInputType.text,
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
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                  validator: (value) => _validateRequired(value, 'Court name'),
                ),
                const SizedBox(height: 16),

                // Schedules Section
                const Text(
                  'Schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add court schedules with specific times',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),

                // Schedule List
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Court Schedules',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No schedules added yet\nTap "Add Schedule" to begin',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _schedules.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
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
                                        tooltip: 'Edit Schedule',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeSchedule(index),
                                        tooltip: 'Remove Schedule',
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
                const SizedBox(height: 24),

                // Pricing Section
                const Text(
                  'Pricing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) => _validatePrice(value, 'Court rate'),
                ),
                const SizedBox(height: 16),

                // Shuttle Cock Price
                TextFormField(
                  controller: _shuttleCockPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Shuttle Cock Price *',
                    hintText: '15.00',
                    prefixIcon: Icon(Icons.sports),
                    suffixText: 'per game',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) => _validatePrice(value, 'Shuttle cock price'),
                ),
                const SizedBox(height: 24),

                // Cost Distribution Checkbox
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cost Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text('Divide the court equally among players'),
                          subtitle: Text(
                            _divideCourtEqually 
                                ? 'Court cost will be split equally among all players'
                                : 'You will need to set the rate per game instead of per hour',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: _divideCourtEqually,
                          activeColor: Colors.amber,
                          onChanged: (bool? value) {
                            setState(() {
                              _divideCourtEqually = value ?? true;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Divide shuttle cost equally among players'),
                          subtitle: Text(
                            _divideShuttleEqually 
                                ? 'Shuttle cost will be split equally among all players'
                                : 'One player pays the full shuttle cost (e.g., if they lose it)',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          value: _divideShuttleEqually,
                          activeColor: Colors.amber,
                          onChanged: (bool? value) {
                            setState(() {
                              _divideShuttleEqually = value ?? true;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        // const SizedBox(height: 16),
                        // Container(
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.all(12),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blue.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(8),
                        //     border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       const Text(
                        //         'Cost Preview (for 4 players)',
                        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        //       ),
                        //       const SizedBox(height: 8),
                        //       _buildCostPreview(),
                        //     ],
                        //   ),
                        // ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveGame,
                        child: const Text(
                          'Save Game',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _cancelGame,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.amber),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Required fields note
                const Row(
                  children: [
                    Text(
                      '* Required fields',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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

// Schedule Dialog for adding/editing schedules
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

  @override
  void dispose() {
    _courtNumberController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        if (_endTime.hour < _startTime.hour || 
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
        }
      });
    }
  }

  void _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
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

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.schedule == null ? 'Add Schedule' : 'Edit Schedule',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Court Number
              TextFormField(
                controller: _courtNumberController,
                decoration: const InputDecoration(
                  labelText: 'Court Number *',
                  hintText: 'e.g., 1, 2, A, B',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Court number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveSchedule,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}