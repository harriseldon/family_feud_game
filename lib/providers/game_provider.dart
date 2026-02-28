import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/game_data.dart';
import '../database/database_helper.dart';

enum GamesSounds { themeSong, goodAnswer, tryAgain }

class GameProvider extends ChangeNotifier {
  List<GameQuestion> _questions = [];
  bool _isLoading = false;

  final player = AudioPlayer();

  List<GameQuestion> get questions => _questions;
  bool get isLoading => _isLoading;

  GameProvider() {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _questions = await DatabaseHelper.instance.getAllQuestions();
    } catch (e) {
      debugPrint('Error loading questions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addQuestion(GameQuestion question) async {
    try {
      await DatabaseHelper.instance.createQuestion(question);
      await loadQuestions();
    } catch (e) {
      debugPrint('Error adding question: $e');
    }
  }

  Future<void> deleteQuestion(int index) async {
    try {
      await DatabaseHelper.instance.deleteQuestion(index);
      await loadQuestions();
    } catch (e) {
      debugPrint('Error deleting question: $e');
    }
  }

  Future<void> clearQuestions() async {
    try {
      await DatabaseHelper.instance.clearAllQuestions();
      await loadQuestions();
    } catch (e) {
      debugPrint('Error clearing questions: $e');
    }
  }

  void resetQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      for (var response in _questions[index].responses) {
        response.isRevealed = false;
      }
      notifyListeners();
    }
  }

  void revealResponse(int questionIndex, int responseIndex) {
    if (questionIndex >= 0 && questionIndex < _questions.length) {
      if (responseIndex >= 0 &&
          responseIndex < _questions[questionIndex].responses.length) {
        playSound(GamesSounds.goodAnswer);
        _questions[questionIndex].responses[responseIndex].isRevealed = true;
        notifyListeners();
      }
    }
  }

  int getTotalScore(int questionIndex) {
    if (questionIndex >= 0 && questionIndex < _questions.length) {
      return _questions[questionIndex].responses
          .where((r) => r.isRevealed)
          .fold(0, (sum, r) => sum + r.points);
    }
    return 0;
  }

  Future<void> playSound(GamesSounds sound) async {
    final soundSource = switch (sound) {
      GamesSounds.themeSong => AssetSource('sounds/family-feud-theme.mp3'),

      GamesSounds.goodAnswer => AssetSource(
        'sounds/family-feud-good-answer.mp3',
      ),

      GamesSounds.tryAgain => AssetSource('sounds/try-again.mp3'),
    };

    await player.play(soundSource);
  }

  @override
  void dispose() {
    // dispose the audio player instance
    player.dispose();
    super.dispose();
  }
}
