import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badminton_player_system/model/user_settings.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _courtNameController = TextEditingController();
  final TextEditingController _courtRateController = TextEditingController();
  final TextEditingController _shuttleCockPriceController = TextEditingController();
  
  // Checkbox state
  bool _divideCourtEqually = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttleCockPriceController.dispose();
    super.dispose();
  }

  // Load existing settings from UserSettings class
  void _loadUserSettings() {
    _courtNameController.text = UserSettings.defaultCourtName;
    _courtRateController.text = UserSettings.defaultCourtRate.toString();
    _shuttleCockPriceController.text = UserSettings.defaultShuttleCockPrice.toString();
    _divideCourtEqually = UserSettings.defaultDivideCourtEqually;
  }

  // Save settings to UserSettings class
  void _saveUserSettings() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save to UserSettings class
    UserSettings.updateCourtName(_courtNameController.text);
    UserSettings.updateCourtRate(_courtRateController.text);
    UserSettings.updateShuttleCockPrice(_shuttleCockPriceController.text);
    UserSettings.updateDivideCourtEqually(_divideCourtEqually);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Reset settings to default
  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _courtNameController.text = 'Badminton Court 1';
                _courtRateController.text = '50.00';
                _shuttleCockPriceController.text = '15.00';
                _divideCourtEqually = true;
              });
              
              // Reset UserSettings
              UserSettings.updateCourtName('Badminton Court 1');
              UserSettings.updateCourtRate('50.00');
              UserSettings.updateShuttleCockPrice('15.00');
              UserSettings.updateDivideCourtEqually(true);
              
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // Validation methods
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
          'User Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
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
                // Section Header
                const Text(
                  'Default Game Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure default values for new games',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Default Court Name
                TextFormField(
                  controller: _courtNameController,
                  decoration: const InputDecoration(
                    labelText: 'Default Court Name *',
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

                // Default Court Rate
                TextFormField(
                  controller: _courtRateController,
                  decoration: const InputDecoration(
                    labelText: 'Default Court Rate (per hour) *',
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

                // Default Shuttle Cock Price
                TextFormField(
                  controller: _shuttleCockPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Default Shuttle Cock Price *',
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

                // Checkbox for dividing court equally
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Information Card
                Card(
                  color: Colors.amber.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              'About These Settings',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• These values will be used as defaults when creating new games',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '• Court rate is typically divided among 4 players in doubles',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '• Shuttle cock cost can be shared or charged to one player',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '• You can always modify these values when creating individual games',
                          style: TextStyle(fontSize: 14),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveUserSettings,
                        child: const Text(
                          'Save Settings',
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
                        onPressed: _resetToDefaults,
                        child: const Text(
                          'Reset Defaults',
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