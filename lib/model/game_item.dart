import 'package:badminton_player_system/model/player_items.dart';

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
  final List<PlayerItem>? queuedPlayers;

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
    this.queuedPlayers,
  });

  // Calculate TOTAL cost for the entire game (always the same regardless of division method)
  double get totalCost {
    double courtCost = 0;
    for (var schedule in schedules) {
      courtCost += courtRate * schedule.durationInHours;
    }
    return courtCost + shuttleCockPrice;
  }

  // Get actual number of players (from queued players if available, otherwise numberOfPlayers)
  int get actualPlayerCount {
    return queuedPlayers?.length ?? numberOfPlayers;
  }

  // Calculate cost per player based on division method
  double get costPerPlayer {
    if (divideCourtEqually && actualPlayerCount > 0) {
      // Divide total cost equally among all players
      return totalCost / actualPlayerCount;
    } else {
      // Individual payment - each player pays full cost or their portion
      return totalCost;
    }
  }

  // Display text for cost information
  String get costDisplayText {
    if (divideCourtEqually && actualPlayerCount > 0) {
      return '₱${costPerPlayer.toStringAsFixed(2)} per player (₱${totalCost.toStringAsFixed(2)} total)';
    } else if (divideCourtEqually && actualPlayerCount == 0) {
      return '₱${totalCost.toStringAsFixed(2)} total (to be split equally)';
    } else {
      return '₱${totalCost.toStringAsFixed(2)} total (individual payment)';
    }
  }

  // Payment method description
  String get paymentMethodDescription {
    return divideCourtEqually 
        ? 'Cost shared equally among players'
        : 'Individual payment based on usage';
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