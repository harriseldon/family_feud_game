class GameResponse {
  final String text;
  final int points;
  bool isRevealed;

  GameResponse({
    required this.text,
    required this.points,
    this.isRevealed = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'points': points,
        'isRevealed': isRevealed,
      };

  factory GameResponse.fromJson(Map<String, dynamic> json) => GameResponse(
        text: json['text'] as String,
        points: json['points'] as int,
        isRevealed: json['isRevealed'] as bool? ?? false,
      );
}

class GameQuestion {
  final String question;
  final List<GameResponse> responses;

  GameQuestion({
    required this.question,
    required this.responses,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'responses': responses.map((r) => r.toJson()).toList(),
      };

  factory GameQuestion.fromJson(Map<String, dynamic> json) => GameQuestion(
        question: json['question'] as String,
        responses: (json['responses'] as List)
            .map((r) => GameResponse.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}
