class Badge {
  final String id;
  final String name;
  final String description;
  final String category;
  final String rarity;
  final String metric;
  final String operator;
  final num value;
  final String asset;
  final String shareTemplate;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.metric,
    required this.operator,
    required this.value,
    required this.asset,
    required this.shareTemplate,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    final criteria = (json['unlockCriteria'] as Map<String, dynamic>? ?? {});
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'streak',
      rarity: json['rarity'] as String? ?? 'common',
      metric: criteria['metric'] as String? ?? '',
      operator: criteria['operator'] as String? ?? '>=',
      value: criteria['value'] as num? ?? 0,
      asset: json['asset'] as String,
      shareTemplate: json['shareTemplate'] as String,
    );
  }
}

class BadgeUnlock {
  final Badge badge;
  final num achievedValue;

  const BadgeUnlock({required this.badge, required this.achievedValue});
}

class BadgeCollectionState {
  final Badge badge;
  final DateTime? unlockedAt;

  const BadgeCollectionState({required this.badge, required this.unlockedAt});

  bool get isUnlocked => unlockedAt != null;
}
