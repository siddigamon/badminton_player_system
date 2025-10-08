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

// const levelIcons = {
//   BadmintonLevel.beginners: Icons.sports_tennis,
//   BadmintonLevel.intermediate: Icons.sports,
//   BadmintonLevel.levelG: Icons.star_border,
//   BadmintonLevel.levelF: Icons.star_half,
//   BadmintonLevel.levelE: Icons.star,
//   BadmintonLevel.levelD: Icons.stars,
//   BadmintonLevel.openPlayer: Icons.emoji_events,
// };

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

  final BadmintonLevel rangeStartLevel;
  final LevelStrength rangeStartStrength;
  final BadmintonLevel rangeEndLevel;
  final LevelStrength rangeEndStrength;

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
    required this.rangeStartLevel,
    required this.rangeStartStrength,
    required this.rangeEndLevel,
    required this.rangeEndStrength,
  });

  String get formattedDateJoined {
    final formatter = DateFormat.yMd();
    return formatter.format(dateJoined);
  }

  String _getLevelDisplayText(BadmintonLevel level) {
    switch (level) {
      case BadmintonLevel.beginners:
        return 'Beginners';
      case BadmintonLevel.intermediate:
        return 'Intermediate';
      case BadmintonLevel.levelG:
        return 'G';
      case BadmintonLevel.levelF:
        return 'F';
      case BadmintonLevel.levelE:
        return 'E';
      case BadmintonLevel.levelD:
        return 'D';
      case BadmintonLevel.openPlayer:
        return 'Open';
    }
  }

  String _getStrengthDisplayText(LevelStrength strength) {
    switch (strength) {
      case LevelStrength.weak:
        return 'Weak';
      case LevelStrength.mid:
        return 'Mid';
      case LevelStrength.strong:
        return 'Strong';
    }
  }

  String get rangeDescription {
    final startStrength = _getStrengthDisplayText(rangeStartStrength);
    final startLevel = _getLevelDisplayText(rangeStartLevel);
    final endStrength = _getStrengthDisplayText(rangeEndStrength);
    final endLevel = _getLevelDisplayText(rangeEndLevel);

    return '$startStrength $startLevel, $endStrength $endLevel';
  }
}
