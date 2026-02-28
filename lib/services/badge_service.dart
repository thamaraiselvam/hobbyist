import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/badge.dart';
import '../models/hobby.dart';
import 'hobby_service.dart';

class BadgeService {
  BadgeService({
    HobbyService? hobbyService,
    Future<String?> Function(String key)? getSetting,
    Future<void> Function(String key, String value)? setSetting,
  }) : _hobbyService = hobbyService ?? HobbyService(),
       _getSetting = getSetting,
       _setSetting = setSetting;

  final HobbyService _hobbyService;
  final Future<String?> Function(String key)? _getSetting;
  final Future<void> Function(String key, String value)? _setSetting;
  List<Badge>? _cache;

  Future<List<Badge>> loadBadges() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(
      'assets/images/badges/badge_catalog.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final badges = (data['badges'] as List<dynamic>)
        .map((e) => Badge.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = badges;
    return badges;
  }

  Future<List<BadgeUnlock>> evaluateNewUnlocks(
    List<Hobby> hobbies, {
    List<Badge>? badgesOverride,
    DateTime? now,
  }) async {
    final badges = badgesOverride ?? await loadBadges();
    final unlocked = await _getUnlockMetadata();
    final metrics = _computeMetrics(hobbies, now: now);

    final newlyUnlocked = <BadgeUnlock>[];
    final unlockTime = (now ?? DateTime.now()).toIso8601String();

    for (final badge in badges) {
      if (unlocked.containsKey(badge.id)) continue;
      final currentValue = metrics[badge.metric];
      if (currentValue == null) continue;
      if (_matchesRule(currentValue, badge.operator, badge.value.toDouble())) {
        newlyUnlocked.add(BadgeUnlock(badge: badge, achievedValue: currentValue));
        unlocked[badge.id] = unlockTime;
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveUnlockMetadata(unlocked);
    }
    return newlyUnlocked;
  }

  Future<List<BadgeCollectionState>> getCollectionStates() async {
    final badges = await loadBadges();
    final metadata = await _getUnlockMetadata();

    return badges.map((badge) {
      final raw = metadata[badge.id];
      return BadgeCollectionState(
        badge: badge,
        unlockedAt: raw == null ? null : DateTime.tryParse(raw),
      );
    }).toList();
  }

  String criteriaText(Badge badge) {
    final value = badge.value % 1 == 0
        ? badge.value.toInt().toString()
        : badge.value.toString();
    switch (badge.metric) {
      case 'streakDays':
        return 'Reach a streak of $value days';
      case 'weeklyCompletionRate':
        return 'Reach $value% completion in the last 7 days';
      case 'totalCompletions':
        return 'Complete $value total task${badge.value == 1 ? '' : 's'}';
      default:
        return 'Satisfy: ${badge.metric} ${badge.operator} $value';
    }
  }

  Future<File> createShareCardSvg(BadgeUnlock unlock) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${unlock.badge.id}_share_card.svg');
    final displayValue = unlock.achievedValue % 1 == 0
        ? unlock.achievedValue.toInt().toString()
        : unlock.achievedValue.toStringAsFixed(1);

    final content = '''<svg width="1080" height="1080" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="120" y1="40" x2="960" y2="1020" gradientUnits="userSpaceOnUse">
      <stop stop-color="#1A1625"/>
      <stop offset="1" stop-color="#2A2238"/>
    </linearGradient>
    <linearGradient id="panel" x1="210" y1="180" x2="860" y2="900" gradientUnits="userSpaceOnUse">
      <stop stop-color="#342A4C"/>
      <stop offset="1" stop-color="#231C34"/>
    </linearGradient>
  </defs>
  <rect width="1080" height="1080" fill="url(#bg)"/>
  <rect x="120" y="130" width="840" height="820" rx="56" fill="url(#panel)"/>
  <circle cx="540" cy="350" r="120" fill="#6C3FFF"/>
  <text x="540" y="370" text-anchor="middle" fill="white" font-family="Arial" font-size="68" font-weight="700">$displayValue</text>
  <text x="540" y="510" text-anchor="middle" fill="white" font-family="Arial" font-size="66" font-weight="700">${unlock.badge.name}</text>
  <text x="540" y="585" text-anchor="middle" fill="#CFC6FF" font-family="Arial" font-size="38">${unlock.badge.description}</text>
  <rect x="180" y="760" width="720" height="130" rx="28" fill="#6C3FFF"/>
  <text x="540" y="818" text-anchor="middle" fill="white" font-family="Arial" font-size="36" font-weight="700">Install Hobbyist</text>
  <text x="540" y="860" text-anchor="middle" fill="#E5DAFF" font-family="Arial" font-size="30">hobbyist.app/install</text>
</svg>''';

    await file.writeAsString(content);
    return file;
  }

  Future<Map<String, String>> _getUnlockMetadata() async {
    final raw = await (_getSetting?.call('badge_unlock_metadata') ??
            _hobbyService.getSetting('badge_unlock_metadata')) ??
        '';
    if (raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUnlockMetadata(Map<String, String> metadata) async {
    await (_setSetting?.call('badge_unlock_metadata', jsonEncode(metadata)) ??
        _hobbyService.setSetting('badge_unlock_metadata', jsonEncode(metadata)));
  }

  Map<String, double> _computeMetrics(List<Hobby> hobbies, {DateTime? now}) {
    final streak = _globalStreak(hobbies, now: now).toDouble();
    final weeklyRate = _weeklyCompletionRate(hobbies, now: now);
    final totalCompletions = hobbies
        .map((h) => h.completions.values.where((c) => c.completed).length)
        .fold<int>(0, (a, b) => a + b)
        .toDouble();

    return {
      'streakDays': streak,
      'weeklyCompletionRate': weeklyRate,
      'totalCompletions': totalCompletions,
    };
  }

  int _globalStreak(List<Hobby> hobbies, {DateTime? now}) {
    if (hobbies.isEmpty) return 0;
    final dateNow = now ?? DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = dateNow.subtract(Duration(days: i));
      final key = fmt.format(date);
      final any = hobbies.any((h) => h.completions[key]?.completed == true);
      if (any) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  double _weeklyCompletionRate(List<Hobby> hobbies, {DateTime? now}) {
    final dateNow = now ?? DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = dateNow.subtract(Duration(days: i));
      final key = fmt.format(date);
      final completed = hobbies.any((h) => h.completions[key]?.completed == true);
      if (completed) completedDays++;
    }

    return (completedDays / 7 * 100).clamp(0, 100);
  }

  bool _matchesRule(double currentValue, String operator, double threshold) {
    switch (operator) {
      case '>=':
        return currentValue >= threshold;
      case '>':
        return currentValue > threshold;
      case '==':
        return currentValue == threshold;
      default:
        return false;
    }
  }
}
