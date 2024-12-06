import 'dart:math';
import 'package:flutter/material.dart';
import 'wordMain.dart';

enum PracticeType { translation, fillInTheBlank }

class PracticeScreen extends StatefulWidget {
  final WordStorage wordStorage;

  PracticeScreen({required this.wordStorage});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  PracticeType? _selectedPracticeType; //Enum to track the selected practice mode (translation or fillInTheBlank)
  List<Word> _words = [];
  Word? _currentWord;
  String? _currentQuestion;
  String? _userAnswer;
  String _feedback = '';
  bool _isAnswered = false;
  bool _isCorrect = false;

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

  void _startPractice(PracticeType type) {
    if (_words.isEmpty) {
      setState(() {
        _feedback = 'No words available. Please add words first.';
      });
      return;
    }

    setState(() {
      _selectedPracticeType = type;
      _isAnswered = false;
      _feedback = '';
      _userAnswer = '';
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    final random = Random();
    _currentWord = _words[random.nextInt(_words.length)];

    if (_selectedPracticeType == PracticeType.translation) {
      _currentQuestion = 'Translate the word "${_currentWord!.word}"';
    }
    else if (_selectedPracticeType == PracticeType.fillInTheBlank) {
      String example = _currentWord!.example;
      String blank = '____';
      _currentQuestion = example.replaceAll(_currentWord!.word, blank);
    }
  }

  void _submitAnswer() {
    if (_currentWord == null) return;

    String correctAnswer;
    bool wasCorrect = false;

    if (_selectedPracticeType == PracticeType.translation) {
      correctAnswer = _currentWord!.translation.toLowerCase();
      if ((_userAnswer ?? '').toLowerCase() == correctAnswer) {
        _feedback = 'Correct!';
        wasCorrect = true;
      } else {
        _feedback = 'Incorrect. The correct translation is "${_currentWord!.translation}".';
      }
    }
    else if (_selectedPracticeType == PracticeType.fillInTheBlank) {
      correctAnswer = _currentWord!.word.toLowerCase();
      if ((_userAnswer ?? '').toLowerCase() == correctAnswer) {
        _feedback = 'Correct!';
        wasCorrect = true;
      } else {
        _feedback = 'Incorrect. The correct word is "${_currentWord!.word}".';
      }
    }

    setState(() {
      _isAnswered = true;
      _isCorrect = wasCorrect;
    });
  }

  void _nextQuestion() {
    setState(() {
      _isAnswered = false;
      _feedback = '';
      _userAnswer = '';
      _generateQuestion();
    });
  }

  void _resetPracticeState() {
    setState(() {
      _selectedPracticeType = null; // For going back to practice selection screen
      _feedback = ''; // Clear feedback message
      _isAnswered = false; // Reset answer status
      _isCorrect = false; // Reset correctness
      _userAnswer = ''; // Clear user input
      _currentWord = null; // Clear current word
      _currentQuestion = null; // Clear current question
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedPracticeType != null) {
          _resetPracticeState(); // Reset state variables
          return false; // Prevent default back navigation
        }
        return true; // Allow default navigation if already on the selection screen
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedPracticeType == null ? 'Practice' : 'Practice Mode',
          ),
          leading: _selectedPracticeType != null
              ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _resetPracticeState(); // Reset state variables
            },
          )
              : null,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedPracticeType == null) _buildPracticeSelection(context),
              if (_selectedPracticeType != null) _buildPracticeQuestion(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeSelection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Select Practice Type:',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Translation Exercise',
              child: ElevatedButton(
                onPressed: () => _startPractice(PracticeType.translation),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Icon(Icons.translate, color: Colors.white, size: 30),
              ),
            ),
            SizedBox(width: 20),
            Tooltip(
              message: 'Fill in the Blank',
              child: ElevatedButton(
                onPressed: () => _startPractice(PracticeType.fillInTheBlank),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        if (_feedback.isNotEmpty)
          Text(
            _feedback,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildPracticeQuestion(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.only(top: 20),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentQuestion ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    _userAnswer = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    hintText: 'Type your answer here...',
                  ),
                ),
                SizedBox(height: 20),
                Tooltip(
                  message: 'Submit Answer',
                  child: ElevatedButton(
                    onPressed: _isAnswered ? null : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16.0),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        if (_feedback.isNotEmpty) _buildFeedbackCard(context),
      ],
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    bool correct = _isCorrect;
    Color feedbackColor = correct ? Colors.green[600]! : Colors.redAccent;
    IconData feedbackIcon = correct ? Icons.check_circle : Icons.error;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(feedbackIcon, color: feedbackColor, size: 40),
            SizedBox(height: 10),
            Text(
              _feedback,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: feedbackColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (_isAnswered)
              Tooltip(
                message: 'Next Question',
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16.0),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}