import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

  Future<File> createShareCardImage(BadgeUnlock unlock) async {
    const width = 1080.0;
    const height = 1080.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final bgRect = const ui.Rect.fromLTWH(0, 0, width, height);
    final bgPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(120, 40),
        const ui.Offset(960, 1020),
        const [ui.Color(0xFF1A1625), ui.Color(0xFF2A2238)],
      );
    canvas.drawRect(bgRect, bgPaint);

    final panelRect = ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(120, 130, 840, 820),
      const ui.Radius.circular(56),
    );
    final panelPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(210, 180),
        const ui.Offset(860, 900),
        const [ui.Color(0xFF342A4C), ui.Color(0xFF231C34)],
      );
    canvas.drawRRect(panelRect, panelPaint);

    canvas.drawCircle(
      const ui.Offset(540, 350),
      120,
      ui.Paint()..color = const ui.Color(0xFF6C3FFF),
    );

    final displayValue = unlock.achievedValue % 1 == 0
        ? unlock.achievedValue.toInt().toString()
        : unlock.achievedValue.toStringAsFixed(1);

    _drawCenteredText(
      canvas,
      displayValue,
      y: 315,
      size: 68,
      color: const ui.Color(0xFFFFFFFF),
      weight: ui.FontWeight.w700,
    );

    _drawCenteredText(
      canvas,
      unlock.badge.name,
      y: 478,
      size: 66,
      color: const ui.Color(0xFFFFFFFF),
      weight: ui.FontWeight.w700,
    );

    _drawCenteredText(
      canvas,
      unlock.badge.description,
      y: 548,
      size: 38,
      color: const ui.Color(0xFFCFC6FF),
      maxWidth: 760,
    );

    final ctaRect = ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(180, 760, 720, 130),
      const ui.Radius.circular(28),
    );
    canvas.drawRRect(ctaRect, ui.Paint()..color = const ui.Color(0xFF6C3FFF));

    _drawCenteredText(
      canvas,
      'Install Hobbyist',
      y: 790,
      size: 36,
      color: const ui.Color(0xFFFFFFFF),
      weight: ui.FontWeight.w700,
    );
    _drawCenteredText(
      canvas,
      'hobbyist.app/install',
      y: 840,
      size: 30,
      color: const ui.Color(0xFFE5DAFF),
    );

    final image = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = bytes?.buffer.asUint8List() ?? Uint8List(0);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${unlock.badge.id}_share_card.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }

  void _drawCenteredText(
    ui.Canvas canvas,
    String text, {
    required double y,
    required double size,
    required ui.Color color,
    ui.FontWeight weight = ui.FontWeight.w400,
    double maxWidth = 1000,
  }) {
    final style = ui.TextStyle(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    );
    final builder = ui.ParagraphBuilder(paragraphStyle)..pushStyle(style)..addText(text);
    final paragraph = builder.build()..layout(ui.ParagraphConstraints(width: maxWidth));
    canvas.drawParagraph(paragraph, ui.Offset((1080 - maxWidth) / 2, y));
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
    for (int i = 0; i < 3650; i++) {
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
