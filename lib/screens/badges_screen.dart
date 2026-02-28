import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../models/badge.dart';
import '../services/badge_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final BadgeService _badgeService = BadgeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        title: const Text('Badges'),
      ),
      body: FutureBuilder<List<BadgeCollectionState>>(
        future: _badgeService.getCollectionStates(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final states = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: states.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final state = states[index];
              return _buildBadgeCard(state);
            },
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard(BadgeCollectionState state) {
    final badge = state.badge;

    return GestureDetector(
      onTap: () => _showBadgeInfo(state),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2238),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: state.isUnlocked
                ? const Color(0xFF8B5CF6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Opacity(
                opacity: state.isUnlocked ? 1 : 0.35,
                child: Center(
                  child: SvgPicture.asset(
                    badge.asset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: state.isUnlocked ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.isUnlocked
                  ? _formatUnlockDate(state.unlockedAt!)
                  : 'Locked',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFCFC6FF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUnlockDate(DateTime date) {
    return 'Unlocked ${DateFormat('MMM d, h:mm a').format(date)}';
  }

  Future<void> _showBadgeInfo(BadgeCollectionState state) async {
    final badge = state.badge;
    final details = _badgeService.criteriaText(badge);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(badge.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Opacity(
                  opacity: state.isUnlocked ? 1 : 0.45,
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: SvgPicture.asset(badge.asset),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                badge.description,
                style: const TextStyle(color: Color(0xFFCFC6FF)),
              ),
              const SizedBox(height: 12),
              Text(
                'How to collect',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: const TextStyle(color: Colors.white70),
              ),
              if (state.isUnlocked && state.unlockedAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  _formatUnlockDate(state.unlockedAt!),
                  style: const TextStyle(color: Color(0xFF10B981)),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
