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
    final raw = await rootBundle.loadString('assets/images/badges/badge_catalog.json');
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
  }) async {
    final badges = badgesOverride ?? await loadBadges();
    final unlocked = await _getUnlockedBadgeIds();
    final metrics = _computeMetrics(hobbies);

    final newlyUnlocked = <BadgeUnlock>[];
    for (final badge in badges) {
      if (unlocked.contains(badge.id)) continue;
      final currentValue = metrics[badge.metric];
      if (currentValue == null) continue;
      if (_matchesRule(currentValue, badge.operator, badge.value.toDouble())) {
        newlyUnlocked.add(BadgeUnlock(badge: badge, achievedValue: currentValue));
        unlocked.add(badge.id);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveUnlockedBadgeIds(unlocked);
    }
    return newlyUnlocked;
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

  Future<Set<String>> _getUnlockedBadgeIds() async {
    final raw = await (_getSetting?.call('unlocked_badge_ids') ??
            _hobbyService.getSetting('unlocked_badge_ids')) ??
        '';
    if (raw.trim().isEmpty) return <String>{};
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  Future<void> _saveUnlockedBadgeIds(Set<String> ids) async {
    await (_setSetting?.call('unlocked_badge_ids', ids.join(',')) ??
        _hobbyService.setSetting('unlocked_badge_ids', ids.join(',')));
  }

  Map<String, double> _computeMetrics(List<Hobby> hobbies) {
    final streak = _globalStreak(hobbies).toDouble();
    final weeklyRate = _weeklyCompletionRate(hobbies);
    return {
      'streakDays': streak,
      'weeklyCompletionRate': weeklyRate,
    };
  }

  int _globalStreak(List<Hobby> hobbies) {
    if (hobbies.isEmpty) return 0;
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
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

  double _weeklyCompletionRate(List<Hobby> hobbies) {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    int completedDays = 0;
    int activeDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = fmt.format(date);
      final hasActivity = hobbies.any((h) => h.completions.containsKey(key));
      if (hasActivity) activeDays++;
      final completed = hobbies.any((h) => h.completions[key]?.completed == true);
      if (completed) completedDays++;
    }

    if (activeDays == 0) return 0;
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
