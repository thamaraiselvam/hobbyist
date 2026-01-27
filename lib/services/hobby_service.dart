import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hobby.dart';

class HobbyService {
  static const String _storageKey = 'hobbies';

  Future<List<Hobby>> loadHobbies() async {
    final prefs = await SharedPreferences.getInstance();
    final String? hobbiesJson = prefs.getString(_storageKey);
    
    if (hobbiesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(hobbiesJson);
    return decoded.map((json) => Hobby.fromJson(json)).toList();
  }

  Future<void> saveHobbies(List<Hobby> hobbies) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(hobbies.map((h) => h.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addHobby(Hobby hobby) async {
    final hobbies = await loadHobbies();
    hobbies.add(hobby);
    await saveHobbies(hobbies);
  }

  Future<void> updateHobby(Hobby hobby) async {
    final hobbies = await loadHobbies();
    final index = hobbies.indexWhere((h) => h.id == hobby.id);
    if (index != -1) {
      hobbies[index] = hobby;
      await saveHobbies(hobbies);
    }
  }

  Future<void> deleteHobby(String id) async {
    final hobbies = await loadHobbies();
    hobbies.removeWhere((h) => h.id == id);
    await saveHobbies(hobbies);
  }

  Future<void> toggleCompletion(String hobbyId, String date) async {
    final hobbies = await loadHobbies();
    final index = hobbies.indexWhere((h) => h.id == hobbyId);
    
    if (index != -1) {
      final hobby = hobbies[index];
      final completions = Map<String, HobbyCompletion>.from(hobby.completions);
      final isCompleted = completions[date]?.completed ?? false;
      completions[date] = HobbyCompletion(
        completed: !isCompleted,
        completedAt: !isCompleted ? DateTime.now() : null,
      );
      hobbies[index] = hobby.copyWith(completions: completions);
      await saveHobbies(hobbies);
    }
  }
}
