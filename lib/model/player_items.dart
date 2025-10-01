import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum BadmintonLevel {
  beginners,
  intermediate,
  levelG,
  levelF,
  levelE,
  levelD,
  openPlayer,
}

enum LevelStrength {
  weak,
  mid,
  strong,
}

const levelIcons = {
  BadmintonLevel.beginners: Icons.sports_tennis,
  BadmintonLevel.intermediate: Icons.sports,
  BadmintonLevel.levelG: Icons.star_border,
  BadmintonLevel.levelF: Icons.star_half,
  BadmintonLevel.levelE: Icons.star,
  BadmintonLevel.levelD: Icons.stars,
  BadmintonLevel.openPlayer: Icons.emoji_events,
};

class PlayerItem {
  final String nickname;
  final String fullName;
  final String contactNumber;
  final String email;
  final String address;
  final String remarks;
  final BadmintonLevel level;
  final LevelStrength strength;
  final DateTime dateJoined;

  PlayerItem({
    required this.nickname,
    required this.fullName,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.remarks,
    required this.level,
    required this.strength,
    required this.dateJoined,
  });

  String get formattedDateJoined {
    final formatter = DateFormat.yMd();
    return formatter.format(dateJoined);
  }

  String get levelDisplay {
    switch (level) {
      case BadmintonLevel.beginners:
        return 'Beginners';
      case BadmintonLevel.intermediate:
        return 'Intermediate';
      case BadmintonLevel.levelG:
        return 'Level G';
      case BadmintonLevel.levelF:
        return 'Level F';
      case BadmintonLevel.levelE:
        return 'Level E';
      case BadmintonLevel.levelD:
        return 'Level D';
      case BadmintonLevel.openPlayer:
        return 'Open Player';
    }
  }

  String get strengthDisplay {
    switch (strength) {
      case LevelStrength.weak:
        return 'Weak';
      case LevelStrength.mid:
        return 'Mid';
      case LevelStrength.strong:
        return 'Strong';
    }
  }

  String get fullLevelDescription {
    return '$levelDisplay - $strengthDisplay';
  }
}

class PlayerBucket {
  final BadmintonLevel level;
  final List<PlayerItem> players;

  PlayerBucket({required this.level, required this.players});

  PlayerBucket.forLevel(List<PlayerItem> allPlayers, this.level)
    : players = allPlayers.where((player) => player.level == level).toList();

  int get totalPlayers {
    return players.length;
  }

  List<PlayerItem> getPlayersByStrength(LevelStrength strength) {
    return players.where((player) => player.strength == strength).toList();
  }
}
