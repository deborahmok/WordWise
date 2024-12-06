import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'practice_screen.dart';
import 'word_list_screen.dart';
import 'starred_list.dart';

class Word {
  final String word;
  final String translation;
  final String example;
  bool isStarred;

  Word({
    required this.word,
    required this.translation,
    required this.example,
    this.isStarred = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'translation': translation,
      'example': example,
      'isStarred': isStarred,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      word: map['word'],
      translation: map['translation'],
      example: map['example'],
      isStarred: map['isStarred'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory Word.fromJson(String source) => Word.fromMap(json.decode(source));
}

class WordStorage {
  static const String _storageKey = 'words';

  Future<void> addWord(Word word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> words = prefs.getStringList(_storageKey) ?? [];
    words.add(word.toJson());
    await prefs.setStringList(_storageKey, words);
  }

  Future<List<Word>> getWords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> words = prefs.getStringList(_storageKey) ?? [];
    return words.map((wordJson) => Word.fromJson(wordJson)).toList();
  }

  Future<List<Word>> getStarredWords() async {
    final List<Word> allWords = await getWords();
    return allWords.where((word) => word.isStarred).toList();
  }

  Future<void> updateWords(List<Word> updatedWords) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> words = updatedWords.map((word) => word.toJson()).toList();
    await prefs.setStringList(_storageKey, words);
  }

  Future<void> clearWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final WordStorage _wordStorage = WordStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordWise Webbyyyyy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          titleTextStyle: GoogleFonts.lato(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 40),
            textStyle: TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            backgroundColor: Colors.blueAccent,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      home: HomeScreen(wordStorage: _wordStorage),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final WordStorage wordStorage;

  HomeScreen({required this.wordStorage});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      WordListScreen(wordStorage: widget.wordStorage),
      StarredPage(wordStorage: widget.wordStorage),
      PracticeScreen(wordStorage: widget.wordStorage),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 8),
            Text(
              'WordWise',
              style: GoogleFonts.pacifico(
                fontSize: 24,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Starred',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Practice',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}