import 'package:flutter/material.dart';
import 'wordMain.dart';

class WordListScreen extends StatefulWidget {
  final WordStorage wordStorage;

  WordListScreen({required this.wordStorage});

  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  List<Word> _words = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    List<Word> words = await widget.wordStorage.getWords();
    setState(() {
      _words = words;
    });
  }

  Future<void> _toggleStarred(Word word) async {
    setState(() {
      word.isStarred = !word.isStarred; // Toggle starred status
    });
    await widget.wordStorage.updateWords(_words);
  }

  Future<void> _addWord() async {
    String word = _wordController.text.trim();
    String translation = _translationController.text.trim();
    String example = _exampleController.text.trim();

    if (word.isEmpty || translation.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Word and Translation are required.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Word newWord = Word(
      word: word,
      translation: translation,
      example: example,
    );

    await widget.wordStorage.addWord(newWord);

    // Clear input fields
    _wordController.clear();
    _translationController.clear();
    _exampleController.clear();
    // Reload words
    _loadWords();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a New Word',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _wordController,
          decoration: InputDecoration(labelText: 'Word'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _translationController,
          decoration: InputDecoration(labelText: 'Translation'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _exampleController,
          decoration: InputDecoration(labelText: 'Example Sentence'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addWord,
          child: Text('Add Word'),
        ),
        SizedBox(height: 20),
        Expanded(
          child: _words.isEmpty ? Center(child: Text('No words added yet.')) : ListView.builder(
              itemCount: _words.length,
              itemBuilder: (context, index) {
              final word = _words[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    word.word,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Translation: ${word.translation}\nExample: ${word.example}',
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      word.isStarred ? Icons.star : Icons.star_border,
                      color: word.isStarred ? Colors.yellow : Colors.grey,
                    ),
                    onPressed: () => _toggleStarred(word),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}