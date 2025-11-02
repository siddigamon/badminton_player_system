class GameItem {
  final String id;
  final String gameTitle;
  final String courtName;
  final List<GameSchedule> schedules;
  final double courtRate;
  final double shuttleCockPrice;
  final bool divideCourtEqually;
  final DateTime createdDate;
  final int numberOfPlayers;

  GameItem({
    required this.id,
    required this.gameTitle,
    required this.courtName,
    required this.schedules,
    required this.courtRate,
    required this.shuttleCockPrice,
    required this.divideCourtEqually,
    required this.createdDate,
    this.numberOfPlayers = 0,
  });

  // Calculate total cost
  double get totalCost {
    double courtCost = 0;
    for (var schedule in schedules) {
      if (divideCourtEqually && numberOfPlayers > 0) {
        courtCost += (courtRate * schedule.durationInHours) / numberOfPlayers;
      } else {
        courtCost += courtRate * schedule.durationInHours;
      }
    }
    return courtCost + shuttleCockPrice;
  }

  // Get display title (game title or formatted date if title is empty)
  String get displayTitle {
    if (gameTitle.isNotEmpty) {
      return gameTitle;
    }
    if (schedules.isNotEmpty) {
      final date = schedules.first.startTime;
      return '${date.day}/${date.month}/${date.year} Game';
    }
    return 'Unnamed Game';
  }
}

class GameSchedule {
  final String courtNumber;
  final DateTime startTime;
  final DateTime endTime;

  GameSchedule({
    required this.courtNumber,
    required this.startTime,
    required this.endTime,
  });

  // Calculate duration in hours
  double get durationInHours {
    final duration = endTime.difference(startTime);
    return duration.inMinutes / 60.0;
  }

  // Format schedule display
  String get displayText {
    final startTimeText = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeText = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return 'Court $courtNumber: $startTimeText - $endTimeText';
  }
}