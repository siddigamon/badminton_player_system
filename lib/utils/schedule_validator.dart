import '../model/game_item.dart';
import 'package:flutter/material.dart';

class ScheduleValidator {
  
  /// Check if two individual schedules overlap
  static bool doSchedulesOverlap(GameSchedule schedule1, GameSchedule schedule2) {
    print('🔍 CHECKING OVERLAP:');
    print('  Schedule 1: Court ${schedule1.courtNumber}, ${_formatDateTime(schedule1.startTime)} - ${_formatDateTime(schedule1.endTime)}');
    print('  Schedule 2: Court ${schedule2.courtNumber}, ${_formatDateTime(schedule2.startTime)} - ${_formatDateTime(schedule2.endTime)}');
    
    // Different courts can't overlap
    if (schedule1.courtNumber.toLowerCase() != schedule2.courtNumber.toLowerCase()) {
      print(' Different courts - NO OVERLAP');
      return false;
    }
    print(' Same court - checking dates...');
    
    // Different dates can't overlap
    if (!_isSameDate(schedule1.startTime, schedule2.startTime)) {
      print(' Different dates - NO OVERLAP');
      return false;
    }
    print(' ✅ Same date - checking times...');

    // Check time overlap: Two time periods overlap if:
    // start1 < end2 AND start2 < end1
    bool overlap = schedule1.startTime.isBefore(schedule2.endTime) && 
                   schedule2.startTime.isBefore(schedule1.endTime);
    
    print('  Time overlap check:');
    print('    ${_formatDateTime(schedule1.startTime)} < ${_formatDateTime(schedule2.endTime)}? ${schedule1.startTime.isBefore(schedule2.endTime)}');
    print('    ${_formatDateTime(schedule2.startTime)} < ${_formatDateTime(schedule1.endTime)}? ${schedule2.startTime.isBefore(schedule1.endTime)}');
    print('    OVERLAP RESULT: ${overlap ? "YES - CONFLICT!" : "NO - SAFE"}');
    
    return overlap;
  }
  
  /// Check if a new schedule conflicts with a list of existing schedules
  static GameSchedule? findConflictingSchedule(
    GameSchedule newSchedule, 
    List<GameSchedule> existingSchedules
  ) {
    print('CONFLICT DETECTION STARTED');
    print('New schedule: Court ${newSchedule.courtNumber}, ${_formatDateTime(newSchedule.startTime)} - ${_formatDateTime(newSchedule.endTime)}');
    print('Checking against ${existingSchedules.length} existing schedules:');
    
    for (int i = 0; i < existingSchedules.length; i++) {
      print('\n--- Checking existing schedule ${i + 1}/${existingSchedules.length} ---');
      GameSchedule existingSchedule = existingSchedules[i];
      
      if (doSchedulesOverlap(newSchedule, existingSchedule)) {
        print('\n🚨 CONFLICT FOUND! Returning conflicting schedule.');
        return existingSchedule;
      }
    }
    
    print('\n NO CONFLICTS FOUND - Schedule is safe to add');
    return null;
  }
  
  /// Get a human-readable description of the conflict
  static String getConflictDescription(GameSchedule conflictingSchedule) {
    final startTime = _formatTime(conflictingSchedule.startTime);
    final endTime = _formatTime(conflictingSchedule.endTime);
    final date = _formatDate(conflictingSchedule.startTime);
    
    return 'Court ${conflictingSchedule.courtNumber} on $date from $startTime to $endTime';
  }
  
  /// Show a conflict dialog and return user's choice
  static Future<bool> showConflictDialog(
    context, 
    GameSchedule newSchedule, 
    GameSchedule conflictingSchedule
  ) async {
    print('SHOWING CONFLICT DIALOG');
    
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
            
            // Existing schedule info
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
                  Text(getConflictDescription(conflictingSchedule)),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // New schedule info
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
                  Text(getConflictDescription(newSchedule)),
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
    
    print('User choice: ${result == true ? "Save Anyway" : "Cancel"}');
    return result ?? false;
  }
  
  // Helper methods
  static bool _isSameDate(DateTime date1, DateTime date2) {
    bool same = date1.year == date2.year && 
                date1.month == date2.month && 
                date1.day == date2.day;
    print('    Date comparison: ${_formatDate(date1)} vs ${_formatDate(date2)} = $same');
    return same;
  }
  
  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  static String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }
}