import 'package:flutter/material.dart';

/// A motivational streak card for the Home screen.
///
/// The 7-day indicator uses a **rolling window anchored on today**:
/// index 0 = 6 days ago, index 6 = today.  Labels are computed from the
/// actual calendar day so the row is always accurate regardless of weekday.
///
/// Visual states (per day):
///   • completed (any past day)  → green circle + ✓
///   • today completed           → glowing green circle + ✓
///   • today pending             → orange filled circle + 🔥
///   • missed (past, has hobbies) → dull red circle + ✕
///   • pending (past, no hobbies) → muted grey circle
class StreakMotivationCard extends StatelessWidget {
  /// Number of consecutive days with at least one hobby completed.
  final int currentStreak;

  /// Completion state for the rolling 7-day window.
  /// Index 0 = 6 days ago, index 6 = today.
  final List<bool> completedDaysInWeek;

  /// Whether the user has created at least one hobby.
  /// Drives the missed (red) vs pending (grey) distinction for past days.
  final bool hasHobbies;

  /// Optional user name used in the subtitle.
  final String? userName;

  /// Optional callback invoked when the CTA button is tapped.
  final VoidCallback? onCtaTap;

  const StreakMotivationCard({
    super.key,
    required this.currentStreak,
    required this.completedDaysInWeek,
    required this.hasHobbies,
    this.userName,
    this.onCtaTap,
  }) : assert(
         completedDaysInWeek.length == 7,
         'completedDaysInWeek must have exactly 7 entries (index 6 = today)',
       );

  // ── Color tokens ──────────────────────────────────────────────────────

  static const _cardBg = Color(0xFF2A2238);
  static const _borderColor = Color(0xFF3D3560);
  static const _primaryPurple = Color(0xFF6C3FFF);
  static const _secondaryPurple = Color(0xFF8B5CF6);
  static const _streakOrange = Color(0xFFFF6B35);
  static const _successGreen = Color(0xFF10B981);
  static const _missedRed = Color(0xFF8B3A3A);
  static const _pendingGrey = Color(0xFF3A3A4A);

  static const _dayAbbrs = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ── Copy helpers ──────────────────────────────────────────────────────

  String get _subtitle {
    final name = userName?.trim();
    if (name != null && name.isNotEmpty) return 'Keep it up, $name';
    if (!hasHobbies) return 'Create your first task to start your streak';
    return 'Keep going — you\'re building a great habit';
  }

  String get _ctaLabel =>
      currentStreak == 0 ? 'Start your streak today' : 'Stay Consistent';

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildWeekRow(),
          const SizedBox(height: 12),
          _buildCtaButton(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Current Streak',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            _buildStreakPill(),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          _subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _streakOrange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: _streakOrange, size: 13),
          const SizedBox(width: 3),
          Text(
            '$currentStreak',
            style: const TextStyle(
              color: _streakOrange,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Week indicator ─────────────────────────────────────────────────────

  Widget _buildWeekRow() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        // Rolling window: index 0 = 6 days ago, index 6 = today
        final day = now.subtract(Duration(days: 6 - i));
        final label = _dayAbbrs[day.weekday - 1];
        return _buildDayColumn(label: label, dayIndex: i);
      }),
    );
  }

  Widget _buildDayColumn({required String label, required int dayIndex}) {
    final isToday = dayIndex == 6;
    final isCompleted = completedDaysInWeek[dayIndex];
    // Past day that wasn't completed and the user has hobbies → missed
    final isMissed = !isToday && !isCompleted && hasHobbies;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isToday ? Colors.white : Colors.white38,
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        _buildCircle(
          isCompleted: isCompleted,
          isToday: isToday,
          isMissed: isMissed,
        ),
      ],
    );
  }

  Widget _buildCircle({
    required bool isCompleted,
    required bool isToday,
    required bool isMissed,
  }) {
    // Today completed → glowing green ✓
    if (isCompleted && isToday) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _successGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _successGreen.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      );
    }

    // Past completed → solid green ✓
    if (isCompleted) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: _successGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white.withValues(alpha: 0.9),
          size: 16,
        ),
      );
    }

    // Today pending → orange filled circle + flame
    if (isToday) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _streakOrange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _streakOrange.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.local_fire_department,
          color: Colors.white,
          size: 18,
        ),
      );
    }

    // Past missed (has hobbies) → dull red + ✕
    if (isMissed) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: _missedRed,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: 15,
        ),
      );
    }

    // Pending (no hobbies yet, or future) → muted grey circle
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _pendingGrey,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
    );
  }

  // ── CTA button ─────────────────────────────────────────────────────────

  Widget _buildCtaButton() {
    return GestureDetector(
      onTap: onCtaTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_primaryPurple, _secondaryPurple],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
            const SizedBox(width: 6),
            Text(
              _ctaLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
