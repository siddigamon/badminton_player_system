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
  final String? shuttlePayerPlayerId;

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
    this.shuttlePayerPlayerId,
  });

  double get courtCost {
    double cost = 0;
    for (var schedule in schedules) {
      cost += courtRate * schedule.durationInHours;
    }
    return cost;
  }

  double get courtCostPerPlayer {
    if (divideCourtEqually && actualPlayerCount > 0) {
      return courtCost / actualPlayerCount;
    }
    return 0; 
  }

  double get shuttleCostPerPlayer {
    if (divideShuttleEqually && actualPlayerCount > 0) {
      return shuttleCockPrice / actualPlayerCount; // Split equally
    }
    return 0; 
  }

  double get costPerPlayer {
    return courtCostPerPlayer + shuttleCostPerPlayer;
  }

  double get regularPlayerCost {
    if (divideShuttleEqually) {
      return courtCostPerPlayer + shuttleCostPerPlayer; // Normal split
    } else {
      return courtCostPerPlayer; 
    }
  }

  double get shuttlePayerCost {
    if (divideShuttleEqually) {
      return courtCostPerPlayer + shuttleCostPerPlayer; // Same as everyone
    } else {
      return courtCostPerPlayer + shuttleCockPrice; 
    }
  }

  double getCostForPlayer(PlayerItem player) {
    if (divideCourtEqually && divideShuttleEqually) {
      return costPerPlayer; 
    } else if (divideCourtEqually && !divideShuttleEqually) {
      if (player.fullName == shuttlePayerPlayerId) {
        return courtCostPerPlayer + shuttleCockPrice; 
      } else {
        return courtCostPerPlayer; 
      }
    } else if (!divideCourtEqually && divideShuttleEqually) {
      return shuttleCostPerPlayer; 
    } else {
      return 0; 
    }
  }

  String getCostDisplayForPlayer(PlayerItem player) {
    if (actualPlayerCount == 0) return 'Waiting for players';
    
    final cost = getCostForPlayer(player);
    
    if (divideCourtEqually && divideShuttleEqually) {
      return '₱${cost.toStringAsFixed(2)} (equal split)';
    } else if (divideCourtEqually && !divideShuttleEqually) {
      if (player.fullName == shuttlePayerPlayerId) {
        return '₱${cost.toStringAsFixed(2)} (court + shuttle)';
      } else {
        return '₱${courtCostPerPlayer.toStringAsFixed(2)} (court only)';
      }
    } else if (!divideCourtEqually && divideShuttleEqually) {
      return '₱${shuttleCostPerPlayer.toStringAsFixed(2)} (shuttle only)';
    } else {
      return 'Individual payment';
    }
  }

  PlayerItem? get shuttlePayerPlayer {
    if (shuttlePayerPlayerId == null || queuedPlayers == null) return null;
    try {
      return queuedPlayers!.firstWhere(
        (player) => player.fullName == shuttlePayerPlayerId,
      );
    } catch (e) {
      return null;
    }
  }

  // Cost display logic
  String get costDisplayText {
    if (actualPlayerCount == 0) {
      return '₱${(courtCost + shuttleCockPrice).toStringAsFixed(2)} total (waiting for players)';
    }
    
    if (divideShuttleEqually) {
      final perPlayer = (courtCostPerPlayer + shuttleCostPerPlayer);
      return '₱${perPlayer.toStringAsFixed(2)} per player (everything split)';
    } else {
      if (shuttlePayerPlayerId != null) {
        final shuttlePlayer = shuttlePayerPlayer?.nickname ?? "Someone";
        return '₱${courtCostPerPlayer.toStringAsFixed(2)} each + ₱${shuttleCockPrice.toStringAsFixed(2)} shuttle ($shuttlePlayer pays)';
      } else {
        return '₱${courtCostPerPlayer.toStringAsFixed(2)} each + shuttle assignment needed';
      }
    }
  }

  // Existing methods
  double get totalCost {
    return courtCost + shuttleCockPrice;
  }

  int get actualPlayerCount {
    return queuedPlayers?.length ?? numberOfPlayers;
  }

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