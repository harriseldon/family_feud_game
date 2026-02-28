import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

import 'dart:async';

class GameBoardScreen extends StatefulWidget {
  final int questionIndex;

  const GameBoardScreen({super.key, required this.questionIndex});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen>
    with SingleTickerProviderStateMixin {
  int _xCount = 0;
  bool _showXOverlay = false;
  Timer? _overlayTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _incrementXCount() {
    setState(() {
      _xCount++;
      _showXOverlay = true;
    });

    // Play system error sound
    //SystemSound.play(SystemSoundType.alert);
    Provider.of<GameProvider>(
      context,
      listen: false,
    ).playSound(GamesSounds.tryAgain);

    // Start animation
    _animationController.forward(from: 0.0);

    // Cancel existing timer if any
    _overlayTimer?.cancel();

    // Hide overlay after 5 seconds
    _overlayTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showXOverlay = false;
        });
      }
    });
  }

  void _resetCount() {
    setState(() {
      _xCount = 0;
      _showXOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = Provider.of<GameProvider>(
      context,
      listen: true,
    ).getTotalScore(widget.questionIndex);
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Board - Score $totalScore points'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, size: 32),
              onPressed: _resetCount,
              tooltip: 'Reset Count',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close, size: 32),
              onPressed: _incrementXCount,
              tooltip: 'Add X',
            ),
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (widget.questionIndex >= gameProvider.questions.length) {
            return const Center(child: Text('Question not found'));
          }

          final question = gameProvider.questions[widget.questionIndex];

          final numberOfRows = (question.responses.length / 2).ceil();
          final indexMatrix = _createMatrix(numberOfRows, 2);

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;

                  return Column(
                    children: [
                      // Question header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 32 : 20),
                        color: Colors.blue.shade700,
                        child: Text(
                          question.question,
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Responses grid
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: isTablet ? 3 : 2.5,
                                  crossAxisSpacing: isTablet ? 16 : 8,
                                  mainAxisSpacing: isTablet ? 16 : 8,
                                ),
                            itemCount: question.responses.length,
                            itemBuilder: (context, index) {
                              final row = (index / 2).floor();
                              final col = index % 2;

                              final modifiedIndex = (indexMatrix[row][col]);

                              final response =
                                  question.responses[modifiedIndex];
                              return _buildResponseCard(
                                response,
                                modifiedIndex,
                                isTablet,
                                gameProvider,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // X Overlay
              if (_showXOverlay) _buildXOverlay(),
            ],
          );
        },
      ),
    );
  }

  List<List<int>> _createMatrix(int rows, int cols) {
    return List<List<int>>.generate(
      rows,
      (row) => List<int>.generate(
        cols,
        (col) => row + col * (rows),
        growable: false,
      ),
      growable: false,
    );
  }

  Widget _buildResponseCard(
    dynamic response,
    int index,
    bool isTablet,
    GameProvider gameProvider,
  ) {
    return GestureDetector(
      onTap: () {
        if (!response.isRevealed) {
          gameProvider.revealResponse(widget.questionIndex, index);
        }
      },
      child: Card(
        elevation: 4,
        color: response.isRevealed
            ? Colors.blue.shade600
            : Colors.grey.shade300,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: response.isRevealed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      response.text,
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      '${response.points} points',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: isTablet ? 48 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildXOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: List.generate(
                  _xCount,
                  (index) => Icon(
                    Icons.close,
                    size: 120,
                    color: Colors.red,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
