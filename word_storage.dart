import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'wordMain.dart';

/// Class to handle storage of Words using SharedPreferences.
class WordStorage {
  static const String _storageKey = 'words';

  /// Add a new word to local storage.
  Future<void> addWord(Word word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> words = prefs.getStringList(_storageKey) ?? [];
    words.add(word.toJson());
    await prefs.setStringList(_storageKey, words);
  }

  /// Retrieve all words from local storage.
  Future<List<Word>> getWords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> words = prefs.getStringList(_storageKey) ?? [];

    return words.map((wordJson) => Word.fromJson(wordJson)).toList();
  }

  /// Clear all words from local storage.
  Future<void> clearWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}