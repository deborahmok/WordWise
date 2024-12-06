import 'package:flutter/material.dart';
import 'wordMain.dart';
import 'word_list_screen.dart';

class StarredPage extends StatefulWidget {
  final WordStorage wordStorage;

  StarredPage({required this.wordStorage});

  @override
  _StarredPageState createState() => _StarredPageState();
}

class _StarredPageState extends State<StarredPage> {
  List<Word> _starredWords = [];

  @override
  void initState() {
    super.initState();
    _loadStarredWords();
  }

  Future<void> _loadStarredWords() async {
    List<Word> starredWords = await widget.wordStorage.getStarredWords();
    setState(() {
      _starredWords = starredWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Starred Words')),
      body: _starredWords.isEmpty ? Center(child: Text('No starred words yet.')) : ListView.builder(
        itemCount: _starredWords.length,
        itemBuilder: (context, index) {
          final word = _starredWords[index];
          return Card(
            child: ListTile(
              title: Text(word.word),
              subtitle: Text('Translation: ${word.translation}'),
            ),
          );
        },
      ),
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

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WordListScreen(wordStorage: widget.wordStorage),
      StarredPage(wordStorage: widget.wordStorage),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Starred',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}