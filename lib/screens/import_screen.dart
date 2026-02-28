import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_data.dart';
import '../providers/game_provider.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _responseControllers = [];
  final List<TextEditingController> _pointsControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize 10 response fields
    for (int i = 0; i < 10; i++) {
      _responseControllers.add(TextEditingController());
      _pointsControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _responseControllers) {
      controller.dispose();
    }
    for (var controller in _pointsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final responses = <GameResponse>[];
      
      for (int i = 0; i < 10; i++) {
        if (_responseControllers[i].text.isNotEmpty) {
          responses.add(GameResponse(
            text: _responseControllers[i].text,
            points: int.tryParse(_pointsControllers[i].text) ?? 0,
          ));
        }
      }

      if (responses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one response')),
        );
        return;
      }

      final question = GameQuestion(
        question: _questionController.text,
        responses: responses,
      );

      Provider.of<GameProvider>(context, listen: false).addQuestion(question);

      // Clear form
      _questionController.clear();
      for (var controller in _responseControllers) {
        controller.clear();
      }
      for (var controller in _pointsControllers) {
        controller.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Question'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final padding = isTablet ? 40.0 : 16.0;
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(padding),
              children: [
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: isTablet ? 20 : 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  'Responses (up to 10)',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 8),
                ..._buildResponseFields(isTablet),
                SizedBox(height: isTablet ? 32 : 24),
                ElevatedButton(
                  onPressed: _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 20 : 16,
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Add Question',
                    style: TextStyle(fontSize: isTablet ? 20 : 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildResponseFields(bool isTablet) {
    return List.generate(10, (index) {
      return Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _responseControllers[index],
                decoration: InputDecoration(
                  labelText: 'Response ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: isTablet ? 18 : 14),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 8),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _pointsControllers[index],
                decoration: const InputDecoration(
                  labelText: 'Points',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: isTablet ? 18 : 14),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      );
    });
  }
}
