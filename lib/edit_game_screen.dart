import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badminton_player_system/model/game_item.dart';
import 'package:badminton_player_system/data/game_data.dart';
import 'package:badminton_player_system/utils/schedule_validator.dart'; 


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
      existingSchedules: _schedules, // NEW: Pass current schedules
      hasConflict: (newSchedule, existingSchedules) { // NEW: Conflict checker
        for (var existing in existingSchedules) {
          // Same court check
          if (existing.courtNumber.toLowerCase() != newSchedule.courtNumber.toLowerCase()) continue;
          
          // Same date check
          if (existing.startTime.year != newSchedule.startTime.year ||
              existing.startTime.month != newSchedule.startTime.month ||
              existing.startTime.day != newSchedule.startTime.day) continue;
          
          // Time overlap check: start1 < end2 AND start2 < end1
          if (existing.startTime.isBefore(newSchedule.endTime) && 
              newSchedule.startTime.isBefore(existing.endTime)) {
            return true; // Conflict found
          }
        }
        return false; // No conflicts
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
      existingSchedules: _schedules, // NEW: Pass current schedules  
      hasConflict: (newSchedule, existingSchedules) { // NEW: Same conflict checker
        for (var existing in existingSchedules) {
          if (existing.courtNumber.toLowerCase() != newSchedule.courtNumber.toLowerCase()) continue;
          
          if (existing.startTime.year != newSchedule.startTime.year ||
              existing.startTime.month != newSchedule.startTime.month ||
              existing.startTime.day != newSchedule.startTime.day) continue;
          
          if (existing.startTime.isBefore(newSchedule.endTime) && 
              newSchedule.startTime.isBefore(existing.endTime)) {
            return true;
          }
        }
        return false;
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
  final List<GameSchedule> existingSchedules; 
  final bool Function(GameSchedule, List<GameSchedule>)? hasConflict; 


  const _ScheduleDialog({
    this.schedule,
    required this.onScheduleAdded,
    required this.existingSchedules, 
    this.hasConflict, 
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
        // Auto-adjust end time if it's before start time
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

  void _saveSchedule() async {
  print('\n📅 SAVE SCHEDULE STARTED');
  print('Form valid: ${_formKey.currentState?.validate()}');
  
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

  print('Proposed schedule:');
  print('  Court: ${_courtNumberController.text.trim()}');
  print('  Start: $startDateTime');
  print('  End: $endDateTime');

  // Basic time validation
  if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
    print('❌ Invalid time range - End time must be after start time');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('End time must be after start time'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  print('✅ Time range is valid');

  final newSchedule = GameSchedule(
    courtNumber: _courtNumberController.text.trim(),
    startTime: startDateTime,
    endTime: endDateTime,
  );

  // NEW: Use passed conflict detection function
  if (widget.hasConflict != null) {
    print('🔍 RUNNING CONFLICT CHECK WITH PASSED FUNCTION');
    
    // Create list excluding current schedule if editing
    List<GameSchedule> schedulesToCheck = List.from(widget.existingSchedules);
    if (widget.schedule != null) {
      print('🔄 EDITING MODE - Removing original schedule from conflict check');
      schedulesToCheck.removeWhere((schedule) => 
        schedule.courtNumber == widget.schedule!.courtNumber &&
        schedule.startTime == widget.schedule!.startTime &&
        schedule.endTime == widget.schedule!.endTime
      );
      print('Schedules after removal: ${schedulesToCheck.length}');
    }
    
    if (widget.hasConflict!(newSchedule, schedulesToCheck)) {
      print('🚨 CONFLICT DETECTED - Showing dialog');
      
      // Find the conflicting schedule for display
      GameSchedule? conflictingSchedule;
      for (var existing in schedulesToCheck) {
        if (existing.courtNumber.toLowerCase() == newSchedule.courtNumber.toLowerCase()) {
          // Same date check
          if (existing.startTime.year == newSchedule.startTime.year &&
              existing.startTime.month == newSchedule.startTime.month &&
              existing.startTime.day == newSchedule.startTime.day) {
            // Time overlap check
            if (existing.startTime.isBefore(newSchedule.endTime) && 
                newSchedule.startTime.isBefore(existing.endTime)) {
              conflictingSchedule = existing;
              break;
            }
          }
        }
      }
      
      if (conflictingSchedule != null) {
        final shouldSaveAnyway = await _showConflictDialog(newSchedule, conflictingSchedule);
        if (!shouldSaveAnyway) {
          print('❌ User cancelled - Schedule not saved');
          return;
        } else {
          print('⚠️ User chose to save anyway');
        }
      }
    } else {
      print('✅ NO CONFLICTS - Safe to save');
    }
  } else {
    print('⚠️ No conflict checker provided - Skipping conflict check');
  }

  // Save the schedule
  print('💾 SAVING SCHEDULE');
  widget.onScheduleAdded(newSchedule);
  Navigator.of(context).pop();
  print('✅ Schedule saved and dialog closed');
}

// NEW: Add conflict dialog method
Future<bool> _showConflictDialog(GameSchedule newSchedule, GameSchedule conflictingSchedule) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Schedule Conflict'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The new schedule conflicts with an existing one:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EXISTING:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Court ${conflictingSchedule.courtNumber}: ${conflictingSchedule.startTime.hour}:${conflictingSchedule.startTime.minute.toString().padLeft(2, '0')} - ${conflictingSchedule.endTime.hour}:${conflictingSchedule.endTime.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NEW:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text('Court ${newSchedule.courtNumber}: ${newSchedule.startTime.hour}:${newSchedule.startTime.minute.toString().padLeft(2, '0')} - ${newSchedule.endTime.hour}:${newSchedule.endTime.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          const Text('Do you want to save it anyway?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Save Anyway'),
        ),
      ],
    ),
  );
  
  return result ?? false;
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
            InkWell(
              onTap: _selectStartTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _startTime.format(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectEndTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _endTime.format(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
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