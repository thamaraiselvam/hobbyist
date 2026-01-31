class HobbyData {
  final String emoji;
  final String name;

  const HobbyData({required this.emoji, required this.name});
}

class DefaultHobbies {
  static const List<HobbyData> hobbies = [
    // Fitness & Sports
    HobbyData(emoji: '🏃', name: 'Running'),
    HobbyData(emoji: '🚴', name: 'Cycling'),
    HobbyData(emoji: '🏊', name: 'Swimming'),
    HobbyData(emoji: '🧘', name: 'Yoga'),
    HobbyData(emoji: '💪', name: 'Gym Workout'),
    HobbyData(emoji: '🏋️', name: 'Weight Training'),
    HobbyData(emoji: '🤸', name: 'Stretching'),
    HobbyData(emoji: '⚽', name: 'Football'),
    HobbyData(emoji: '🏀', name: 'Basketball'),
    HobbyData(emoji: '🎾', name: 'Tennis'),
    
    // Creative Arts
    HobbyData(emoji: '🎨', name: 'Painting'),
    HobbyData(emoji: '✏️', name: 'Drawing'),
    HobbyData(emoji: '📸', name: 'Photography'),
    HobbyData(emoji: '🎬', name: 'Video Editing'),
    HobbyData(emoji: '✍️', name: 'Writing'),
    HobbyData(emoji: '🎭', name: 'Acting'),
    HobbyData(emoji: '🎪', name: 'Dance'),
    HobbyData(emoji: '🎤', name: 'Singing'),
    
    // Music
    HobbyData(emoji: '🎸', name: 'Guitar'),
    HobbyData(emoji: '🎹', name: 'Piano'),
    HobbyData(emoji: '🥁', name: 'Drums'),
    HobbyData(emoji: '🎵', name: 'Music Practice'),
    HobbyData(emoji: '🎧', name: 'Listen to Music'),
    
    // Learning & Reading
    HobbyData(emoji: '📚', name: 'Reading'),
    HobbyData(emoji: '📖', name: 'Study'),
    HobbyData(emoji: '💻', name: 'Coding'),
    HobbyData(emoji: '🌐', name: 'Learn Language'),
    HobbyData(emoji: '🎓', name: 'Online Course'),
    HobbyData(emoji: '📝', name: 'Journaling'),
    HobbyData(emoji: '🧮', name: 'Math Practice'),
    
    // Mindfulness & Wellness
    HobbyData(emoji: '🧘‍♀️', name: 'Meditation'),
    HobbyData(emoji: '🙏', name: 'Prayer'),
    HobbyData(emoji: '😴', name: 'Sleep 8 Hours'),
    HobbyData(emoji: '💧', name: 'Drink Water'),
    HobbyData(emoji: '🥗', name: 'Healthy Eating'),
    HobbyData(emoji: '💆', name: 'Self Care'),
    
    // Hobbies & Crafts
    HobbyData(emoji: '🧶', name: 'Knitting'),
    HobbyData(emoji: '🪡', name: 'Sewing'),
    HobbyData(emoji: '🎮', name: 'Gaming'),
    HobbyData(emoji: '🧩', name: 'Puzzle'),
    HobbyData(emoji: '♟️', name: 'Chess'),
    HobbyData(emoji: '🎲', name: 'Board Games'),
    HobbyData(emoji: '🎣', name: 'Fishing'),
    HobbyData(emoji: '🌱', name: 'Gardening'),
    
    // Social & Family
    HobbyData(emoji: '👨‍👩‍👧‍👦', name: 'Family Time'),
    HobbyData(emoji: '👥', name: 'Meet Friends'),
    HobbyData(emoji: '📞', name: 'Call Parents'),
    HobbyData(emoji: '💬', name: 'Social Media Break'),
    
    // Cooking & Food
    HobbyData(emoji: '🍳', name: 'Cooking'),
    HobbyData(emoji: '🍰', name: 'Baking'),
    HobbyData(emoji: '☕', name: 'Coffee Brewing'),
  ];

  static List<HobbyData> search(String query) {
    if (query.isEmpty) {
      return hobbies;
    }
    
    final lowerQuery = query.toLowerCase();
    return hobbies.where((hobby) {
      return hobby.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
