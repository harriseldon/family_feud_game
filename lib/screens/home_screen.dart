import 'package:family_feud_game/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'import_screen.dart';
import 'questions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Feud Game'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;

          return Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 40.0 : 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz,
                    size: isTablet ? 120 : 80,
                    color: Colors.blue,
                  ),
                  SizedBox(height: isTablet ? 40 : 24),
                  Text(
                    'Family Feud Game',
                    style: TextStyle(
                      fontSize: isTablet ? 48 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: isTablet ? 60 : 40),
                  SizedBox(
                    width: isTablet ? 400 : double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImportScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 24 : 20,
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Import Question',
                        style: TextStyle(fontSize: isTablet ? 24 : 20),
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  SizedBox(
                    width: isTablet ? 400 : double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<GameProvider>(
                          context,
                          listen: false,
                        ).playSound(GamesSounds.themeSong);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuestionsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 24 : 20,
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'View Questions',
                        style: TextStyle(fontSize: isTablet ? 24 : 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
