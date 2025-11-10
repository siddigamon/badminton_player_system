import 'package:badminton_player_system/model/player_items.dart';

class GameItem {
  final String id;
  final String gameTitle;
  final String courtName;
  final List<GameSchedule> schedules;
  final double courtRate;
  final double shuttleCockPrice;
  final bool divideCourtEqually;
  final bool divideShuttleEqually;
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
    required this.divideShuttleEqually,  
    required this.createdDate,
    this.numberOfPlayers = 0,
    this.queuedPlayers,
  });

  double get totalCost {
    double courtCost = 0;
    for (var schedule in schedules) {
      courtCost += courtRate * schedule.durationInHours;
    }
    return courtCost + shuttleCockPrice;
  }

  // Get actual number of players 
  int get actualPlayerCount {
    return queuedPlayers?.length ?? numberOfPlayers;
  }

  double get courtCostPerPlayer {
    if (divideCourtEqually && actualPlayerCount > 0) {
      return courtCost / actualPlayerCount;
    }
    return 0; 
  }

  double get shuttleCostPerPlayer {
    if (divideShuttleEqually && actualPlayerCount > 0) {
      return shuttleCockPrice / actualPlayerCount;
    }
    return 0; 
  }

  double get costPerPlayer {
    return courtCostPerPlayer + shuttleCostPerPlayer;
  }

  double get courtCost {
    double cost = 0;
    for (var schedule in schedules) {
      cost += courtRate * schedule.durationInHours;
    }
    return cost;
  }
  String get costDisplayText {
    if (actualPlayerCount == 0) {
      return '₱${totalCost.toStringAsFixed(2)} total (waiting for players)';
    }
    
    if (divideCourtEqually && divideShuttleEqually) {
      return '₱${costPerPlayer.toStringAsFixed(2)} per player (everything split)';
    } else if (divideCourtEqually && !divideShuttleEqually) {
      return '₱${courtCostPerPlayer.toStringAsFixed(2)} per player + ₱${shuttleCockPrice.toStringAsFixed(2)} shuttle (1 player)';
    } else if (!divideCourtEqually && divideShuttleEqually) {
      return 'Individual court cost + ₱${shuttleCostPerPlayer.toStringAsFixed(2)} shuttle per player';
    } else {
      return '₱${totalCost.toStringAsFixed(2)} total (individual payment)';
    }
  }

  // String get paymentMethodDescription {
  //   if (divideCourtEqually && divideShuttleEqually) {
  //     return 'All costs shared equally among players';
  //   } else if (divideCourtEqually && !divideShuttleEqually) {
  //     return 'Court cost shared, shuttle paid by one player';
  //   } else if (!divideCourtEqually && divideShuttleEqually) {
  //     return 'Individual court cost, shuttle shared equally';
  //   } else {
  //     return 'All costs paid individually';
  //   }
  // }

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

  // duration in hours
  double get durationInHours {
    final duration = endTime.difference(startTime);
    return duration.inMinutes / 60.0;
  }

  String get displayText {
    final startTimeText = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeText = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return 'Court $courtNumber: $startTimeText - $endTimeText';
  }
}