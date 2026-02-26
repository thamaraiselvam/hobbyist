class HobbyData {
  final String emoji;
  final String name;
  final List<String> keywords;

  const HobbyData({
    required this.emoji,
    required this.name,
    this.keywords = const [],
  });
}

class _IndexedHobby {
  final HobbyData hobby;
  final String nameLower;
  final String searchableText;
  final List<String> nameTokens;

  const _IndexedHobby({
    required this.hobby,
    required this.nameLower,
    required this.searchableText,
    required this.nameTokens,
  });
}

class DefaultHobbies {
  static const List<HobbyData> hobbies = [
    HobbyData(emoji: '🏃', name: 'Running', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏃‍♀️', name: 'Morning Run', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🚶', name: 'Walking', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🚶‍♀️', name: 'Evening Walk', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🥾', name: 'Hiking', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🚴', name: 'Cycling', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏊', name: 'Swimming', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧘', name: 'Yoga', keywords: ['fitness', 'health']),
    HobbyData(emoji: '💪', name: 'Gym Workout', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏋️', name: 'Weight Training', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🤸', name: 'Stretching', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧎', name: 'Pilates', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏐', name: 'Volleyball', keywords: ['fitness', 'health']),
    HobbyData(emoji: '⚽', name: 'Football', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏀', name: 'Basketball', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🎾', name: 'Tennis', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏸', name: 'Badminton', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏓', name: 'Table Tennis', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🥊', name: 'Boxing', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🥋', name: 'Martial Arts', keywords: ['fitness', 'health']),
    HobbyData(emoji: '⛹️', name: 'Jump Rope', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🛼', name: 'Roller Skating', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🛹', name: 'Skateboarding', keywords: ['fitness', 'health']),
    HobbyData(emoji: '⛸️', name: 'Ice Skating', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏂', name: 'Snowboarding', keywords: ['fitness', 'health']),
    HobbyData(emoji: '⛷️', name: 'Skiing', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏌️', name: 'Golf Practice', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🏹', name: 'Archery', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🤾', name: 'Handball', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧗', name: 'Rock Climbing', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🤽', name: 'Water Polo', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🚣', name: 'Rowing', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧍', name: 'Posture Exercises', keywords: ['fitness', 'health']),
    HobbyData(emoji: '💓', name: 'Cardio Session', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🦵', name: 'Leg Day', keywords: ['fitness', 'health']),
    HobbyData(emoji: '💥', name: 'HIIT Workout', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧠', name: 'Breathing Exercise', keywords: ['fitness', 'health']),
    HobbyData(emoji: '😴', name: 'Sleep 8 Hours', keywords: ['fitness', 'health']),
    HobbyData(emoji: '💧', name: 'Drink Water', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🥗', name: 'Healthy Eating', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🍎', name: 'Eat Fruit', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🥬', name: 'Meal Prep', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧍‍♂️', name: 'Take Stretch Break', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🚭', name: 'No Smoking', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🍺', name: 'No Alcohol Day', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧴', name: 'Skin Care Routine', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🦷', name: 'Dental Care Routine', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🩺', name: 'Take Vitamins', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧘‍♀️', name: 'Meditation', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🙏', name: 'Prayer', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🌞', name: 'Sunlight 15 Minutes', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🛌', name: 'Power Nap', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧊', name: 'Cold Shower', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🔥', name: 'Sauna Session', keywords: ['fitness', 'health']),
    HobbyData(emoji: '👣', name: '10K Steps', keywords: ['fitness', 'health']),
    HobbyData(emoji: '🧘‍♂️', name: 'Mobility Training', keywords: ['fitness', 'health']),
    HobbyData(emoji: '⚖️', name: 'Track Weight', keywords: ['fitness', 'health']),
    HobbyData(emoji: '📉', name: 'Reduce Sugar', keywords: ['fitness', 'health']),
    HobbyData(emoji: '💤', name: 'Sleep Early', keywords: ['fitness', 'health']),
    HobbyData(emoji: '📴', name: 'No Screens Before Bed', keywords: ['fitness', 'health']),
    HobbyData(emoji: '📚', name: 'Reading', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📖', name: 'Read 20 Pages', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📝', name: 'Journaling', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '✍️', name: 'Creative Writing', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '💻', name: 'Coding Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧪', name: 'Build Side Project', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🎓', name: 'Online Course', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🌐', name: 'Learn Language', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧠', name: 'Flashcards Review', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🗣️', name: 'Speaking Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🎧', name: 'Listen to Podcast', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📄', name: 'Write Blog Post', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📰', name: 'Read News Briefing', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🔬', name: 'Research Topic', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📐', name: 'Math Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧾', name: 'Budget Review', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📅', name: 'Plan Tomorrow', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '✅', name: 'Daily Planning', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '⏱️', name: 'Pomodoro Session', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📥', name: 'Inbox Zero', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧹', name: 'Declutter Desk', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🗂️', name: 'Organize Files', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🔍', name: 'Deep Work Session', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📓', name: 'Study Session', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧑‍🏫', name: 'Teach What You Learned', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🔁', name: 'Spaced Repetition', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '💬', name: 'Practice Public Speaking', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '⌨️', name: 'Typing Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🎯', name: 'Set Top 3 Priorities', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🚫', name: 'No Procrastination Hour', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📵', name: 'Focus Mode 60 Minutes', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧭', name: 'Weekly Review', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📆', name: 'Monthly Review', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧱', name: 'One Important Task', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📌', name: 'Update Goals', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📚', name: 'Read Nonfiction', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📘', name: 'Read Fiction', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧾', name: 'Write Gratitude List', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🪄', name: 'Mind Mapping', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧠', name: 'Memory Training', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧩', name: 'Solve Logic Puzzle', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '💡', name: 'Idea Brainstorming', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🗒️', name: 'Take Notes', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📊', name: 'Track Expenses', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🏦', name: 'Save Money Task', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧮', name: 'Accounting Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧠', name: 'Learn New Concept', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🔤', name: 'Vocabulary Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🈯', name: 'Kanji Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🎼', name: 'Music Theory Study', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧬', name: 'Science Reading', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🏛️', name: 'History Study', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🌍', name: 'Geography Study', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '💼', name: 'Career Skill Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧑‍💻', name: 'Code Review Practice', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📈', name: 'Market Research', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📣', name: 'Networking Outreach', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧑‍🎓', name: 'Exam Preparation', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🧷', name: 'Pin Important Notes', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '📖', name: 'Read Before Bed', keywords: ['learning', 'study', 'productivity']),
    HobbyData(emoji: '🎨', name: 'Painting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '✏️', name: 'Drawing', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🖍️', name: 'Sketching', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🖌️', name: 'Watercolor Painting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧵', name: 'Embroidery', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧶', name: 'Knitting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪡', name: 'Sewing', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪢', name: 'Crochet', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪚', name: 'Woodworking', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🛠️', name: 'DIY Project', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '📸', name: 'Photography', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎬', name: 'Video Editing', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎥', name: 'Film Making', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎞️', name: 'Color Grading Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎙️', name: 'Voice Recording', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎭', name: 'Acting Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '💃', name: 'Dance Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🕺', name: 'Choreography Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎤', name: 'Singing Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎼', name: 'Songwriting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎸', name: 'Guitar Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎹', name: 'Piano Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🥁', name: 'Drum Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎻', name: 'Violin Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎺', name: 'Trumpet Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎷', name: 'Saxophone Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪈', name: 'Flute Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎛️', name: 'Music Production', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎚️', name: 'Mixing Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧑‍🍳', name: 'Recipe Creation', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🍳', name: 'Cooking', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🍰', name: 'Baking', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🥐', name: 'Bread Baking', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🍝', name: 'Meal Cooking', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '☕', name: 'Coffee Brewing', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🍵', name: 'Tea Brewing', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🌱', name: 'Gardening', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🌿', name: 'Herb Gardening', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪴', name: 'Plant Care', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧱', name: 'Miniature Building', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧩', name: 'Puzzle Solving', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '♟️', name: 'Chess Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎲', name: 'Board Games', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎮', name: 'Gaming Session', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🕹️', name: 'Retro Gaming', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧠', name: 'Brain Teasers', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '📚', name: 'Scrapbooking', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🖋️', name: 'Calligraphy', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧴', name: 'Candle Making', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧼', name: 'Soap Making', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪙', name: 'Coin Collecting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🪨', name: 'Rock Collecting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '📮', name: 'Postcard Collecting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎟️', name: 'Ticket Collecting', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🏺', name: 'Pottery', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧑‍🎨', name: 'Digital Art Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🛰️', name: 'Drone Flying', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🔭', name: 'Stargazing', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🧭', name: 'Geocaching', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '🎯', name: 'Darts Practice', keywords: ['creative', 'hobby', 'art']),
    HobbyData(emoji: '👨‍👩‍👧‍👦', name: 'Family Time', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '👥', name: 'Meet Friends', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📞', name: 'Call Parents', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '💌', name: 'Message a Friend', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🤝', name: 'Community Volunteering', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧓', name: 'Visit Relatives', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🎉', name: 'Plan Social Event', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📅', name: 'Date Night', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧒', name: 'Kids Activity Time', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🫶', name: 'Acts of Kindness', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧹', name: 'Clean Room (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧺', name: 'Do Laundry (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🛒', name: 'Grocery Shopping (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧽', name: 'Deep Clean Kitchen (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧯', name: 'Safety Check (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '💡', name: 'Pay Electricity Bill (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '💧', name: 'Pay Water Bill (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📶', name: 'Pay Internet Bill (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🏠', name: 'Rent Payment (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📱', name: 'Phone Bill Payment (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧾', name: 'Tax Preparation (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🪪', name: 'Renew ID (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🩺', name: 'Medical Checkup (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '💊', name: 'Refill Medication (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🦷', name: 'Dental Appointment (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🚗', name: 'Car Maintenance (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '⛽', name: 'Fuel Car (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🛞', name: 'Tire Pressure Check (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧰', name: 'Home Repair Task (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🔋', name: 'Charge Devices (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🗑️', name: 'Take Out Trash (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📦', name: 'Package Return (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📬', name: 'Check Mail (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🪴', name: 'Water Plants (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🐶', name: 'Pet Care Routine (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🐱', name: 'Clean Litter Box (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🍱', name: 'Pack Lunch (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🥣', name: 'Prepare Breakfast (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🍽️', name: 'Wash Dishes (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧴', name: 'Refill Essentials (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧊', name: 'Defrost Freezer (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🛏️', name: 'Change Bedsheets (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🪟', name: 'Clean Windows (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🚿', name: 'Bathroom Deep Clean (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📂', name: 'Organize Documents (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🗄️', name: 'Backup Photos (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🔐', name: 'Update Passwords (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '💳', name: 'Credit Card Review (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🏦', name: 'Savings Transfer (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📊', name: 'Review Subscriptions (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧠', name: 'Therapy Session (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📿', name: 'Spiritual Practice (Daily Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🎁', name: 'Gift Planning (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧭', name: 'Travel Planning (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🛄', name: 'Pack for Trip (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧳', name: 'Unpack After Trip (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🧼', name: 'Donate Unused Items (Monthly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📚', name: 'Library Visit (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🏪', name: 'Pharmacy Run (One-time Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '🕯️', name: 'Digital Detox Evening (Weekly Task)', keywords: ['task', 'admin', 'lifestyle']),
    HobbyData(emoji: '📱', name: 'Content Planning', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📝', name: 'Write Social Post', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🎥', name: 'Record Short Video', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '✂️', name: 'Edit Reels', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📈', name: 'Analyze Engagement', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🏷️', name: 'Hashtag Research', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🖼️', name: 'Thumbnail Design', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧠', name: 'Brand Strategy Session', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🤳', name: 'Take Product Photos', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🛍️', name: 'Update Online Store', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧾', name: 'Inventory Check', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📦', name: 'Ship Orders', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '💬', name: 'Reply to Customers', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '⭐', name: 'Request Customer Review', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📣', name: 'Launch Promotion', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🔎', name: 'SEO Optimization', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🌍', name: 'Website Update', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧑‍💼', name: 'Freelance Outreach', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📨', name: 'Client Follow-up', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧾', name: 'Invoice Clients', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🏁', name: 'Project Milestone Review', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧑‍🤝‍🧑', name: 'Team Standup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📊', name: 'KPI Review', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧱', name: 'Build Portfolio', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📹', name: 'Livestream Practice', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🗓️', name: 'Content Calendar Setup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🎙️', name: 'Podcast Recording', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🔊', name: 'Audio Editing', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📚', name: 'Course Creation', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🖥️', name: 'UI Design Practice', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧪', name: 'A/B Test Setup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📤', name: 'Newsletter Writing', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📰', name: 'Publish Newsletter', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '💼', name: 'Resume Update', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧑‍🔧', name: 'Skill Certification Study', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '💳', name: 'Expense Logging', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧾', name: 'Receipt Organization', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧠', name: 'Brain Dump Session', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🎯', name: 'Quarterly Goal Setting', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🏆', name: 'Win Review Session', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🛡️', name: 'Data Backup Task', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '☁️', name: 'Cloud Cleanup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📂', name: 'Desktop File Cleanup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🔌', name: 'Unsubscribe Emails', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🔔', name: 'Notification Cleanup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📵', name: 'Social Media Break', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '⌛', name: 'Screen Time Limit', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '📺', name: 'Watch Tutorial', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧭', name: 'Mentorship Session', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🪜', name: 'Career Ladder Planning', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🤖', name: 'Automation Setup', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🔧', name: 'Tool Maintenance', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🪙', name: 'Investing Research', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🏡', name: 'Real Estate Research', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🗺️', name: 'Vision Board Update', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🧘', name: 'Mindful Breathing Break', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🏞️', name: 'Nature Walk', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🚲', name: 'Commute by Bike', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '♻️', name: 'Recycling Task', keywords: ['digital', 'work', 'task']),
    HobbyData(emoji: '🌍', name: 'Eco-friendly Habit', keywords: ['digital', 'work', 'task']),
  ];

  static final List<_IndexedHobby> _indexedHobbies = hobbies.map((hobby) {
    final nameLower = hobby.name.toLowerCase();
    final keywordText = hobby.keywords.join(' ').toLowerCase();
    final searchableText = keywordText.isEmpty
        ? nameLower
        : '$nameLower $keywordText';
    final nameTokens = nameLower.split(RegExp(r'[^a-z0-9]+')).where((token) => token.isNotEmpty).toList(growable: false);
    return _IndexedHobby(
      hobby: hobby,
      nameLower: nameLower,
      searchableText: searchableText,
      nameTokens: nameTokens,
    );
  }).toList(growable: false);

  static List<HobbyData> search(String query, {int? limit}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return hobbies;
    }

    final queryTokens = normalized.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList(growable: false);
    final matches = <({HobbyData hobby, int score})>[];

    for (final entry in _indexedHobbies) {
      var allTokensFound = true;
      for (final token in queryTokens) {
        if (!entry.searchableText.contains(token)) {
          allTokensFound = false;
          break;
        }
      }
      if (!allTokensFound) {
        continue;
      }

      var score = 0;
      if (entry.nameLower == normalized) {
        score += 1_000;
      }
      if (entry.nameLower.startsWith(normalized)) {
        score += 700;
      }
      if (entry.nameTokens.any((token) => token.startsWith(normalized))) {
        score += 500;
      }
      if (entry.nameLower.contains(normalized)) {
        score += 300;
      }
      for (final token in queryTokens) {
        if (entry.nameTokens.contains(token)) {
          score += 150;
        } else if (entry.nameTokens.any((nameToken) => nameToken.startsWith(token))) {
          score += 100;
        } else {
          score += 30;
        }
      }

      matches.add((hobby: entry.hobby, score: score));
    }

    matches.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return a.hobby.name.compareTo(b.hobby.name);
    });

    final sorted = matches.map((match) => match.hobby);
    if (limit != null && limit > 0) {
      return sorted.take(limit).toList(growable: false);
    }

    return sorted.toList(growable: false);
  }
}
