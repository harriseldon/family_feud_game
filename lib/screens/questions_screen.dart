import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_board_screen.dart';

class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<GameProvider>(
                context,
                listen: false,
              ).clearQuestions();
            },
            icon: Icon(Icons.delete_forever),
            tooltip: 'Delete all questions',
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.questions.isEmpty) {
            return const Center(
              child: Text(
                'No questions imported yet.\nUse the button below to add questions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final itemPadding = isTablet ? 16.0 : 8.0;

              return ListView.builder(
                padding: EdgeInsets.all(itemPadding),
                itemCount: gameProvider.questions.length,
                itemBuilder: (context, index) {
                  final question = gameProvider.questions[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(
                      vertical: itemPadding / 2,
                      horizontal: itemPadding,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                      title: Text(
                        question.question,
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${question.responses.length} responses',
                          style: TextStyle(fontSize: isTablet ? 18 : 14),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: isTablet ? 32 : 24,
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Provider.of<GameProvider>(
                            context,
                            listen: false,
                          ).deleteQuestion(index);
                        },
                      ),
                      onTap: () {
                        // Reset the question when selected
                        gameProvider.resetQuestion(index);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GameBoardScreen(questionIndex: index),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
