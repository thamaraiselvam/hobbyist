import 'package:flutter/material.dart';

/// A motivational streak card displayed at the top of the Home screen.
///
/// Shows the current global streak, a 7-day week indicator with per-day
/// completion states, and a dynamic CTA button — all styled to match the
/// app's dark purple design system.
class StreakMotivationCard extends StatelessWidget {
  /// Number of consecutive days with at least one hobby completed.
  final int currentStreak;

  /// Completion state for each day of the current week (Mon–Sun, index 0–6).
  /// A `true` value means at least one hobby was completed on that day.
  /// Future days should be `false`.
  final List<bool> completedDaysInWeek;

  /// Today's index in the Mon–Sun week (0 = Monday, 6 = Sunday).
  final int currentDayIndex;

  /// Optional callback invoked when the CTA button is tapped.
  final VoidCallback? onCtaTap;

  const StreakMotivationCard({
    super.key,
    required this.currentStreak,
    required this.completedDaysInWeek,
    required this.currentDayIndex,
    this.onCtaTap,
  }) : assert(
         completedDaysInWeek.length == 7,
         'completedDaysInWeek must have exactly 7 entries',
       );

  // ── Color tokens (derived from app theme) ─────────────────────────────

  static const _cardBg = Color(0xFF2A2238);
  static const _borderColor = Color(0xFF3D3560);
  static const _primaryPurple = Color(0xFF6C3FFF);
  static const _secondaryPurple = Color(0xFF8B5CF6);
  static const _streakOrange = Color(0xFFFF6B35);
  static const _successGreen = Color(0xFF10B981);

  // ── Dynamic copy ───────────────────────────────────────────────────────

  String get _subtitle {
    if (currentStreak == 0) return 'Your journey starts now';
    if (currentStreak == 1) return 'Great start — day 1 done!';
    if (currentStreak < 7) return 'Building momentum';
    if (currentStreak < 30) return "You're on a roll!";
    return "You're unstoppable!";
  }

  String get _ctaLabel {
    if (currentStreak == 0) return 'Start your streak today';
    if (currentStreak < 3) return 'Keep the momentum going';
    if (currentStreak < 7) return 'Stay consistent';
    if (currentStreak < 30) return "You're doing great — keep it up";
    return 'Legendary streak — keep going';
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWeekRow(),
          const SizedBox(height: 14),
          _buildCtaButton(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildTitleColumn()),
        const SizedBox(width: 12),
        _buildLogoCircle(),
      ],
    );
  }

  Widget _buildTitleColumn() {
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
          const Icon(
            Icons.local_fire_department,
            color: _streakOrange,
            size: 13,
          ),
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

  Widget _buildLogoCircle() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryPurple, _secondaryPurple],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'H',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  // ── Week indicator ─────────────────────────────────────────────────────

  Widget _buildWeekRow() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        7,
        (i) => _buildDayColumn(label: labels[i], dayIndex: i),
      ),
    );
  }

  Widget _buildDayColumn({required String label, required int dayIndex}) {
    final isToday = dayIndex == currentDayIndex;
    final isFuture = dayIndex > currentDayIndex;
    final isCompleted = completedDaysInWeek[dayIndex];

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isToday
                ? Colors.white
                : isFuture
                    ? Colors.white24
                    : Colors.white38,
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        _buildCircle(
          isCompleted: isCompleted,
          isToday: isToday,
          isFuture: isFuture,
        ),
      ],
    );
  }

  Widget _buildCircle({
    required bool isCompleted,
    required bool isToday,
    required bool isFuture,
  }) {
    if (isCompleted && isToday) {
      // Today completed: vivid green, glowing
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

    if (isCompleted) {
      // Past completed: solid green, no glow
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

    if (isToday) {
      // Today not yet completed: orange border + flame icon
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _streakOrange.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: _streakOrange, width: 2),
          boxShadow: [
            BoxShadow(
              color: _streakOrange.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.local_fire_department,
          color: _streakOrange,
          size: 18,
        ),
      );
    }

    if (isFuture) {
      // Future day: very muted outline, no content
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
      );
    }

    // Past missed: dim outline with subtle ✕
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: const Icon(Icons.close_rounded, color: Colors.white24, size: 13),
    );
  }

  // ── CTA button ─────────────────────────────────────────────────────────

  Widget _buildCtaButton() {
    return GestureDetector(
      onTap: onCtaTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
