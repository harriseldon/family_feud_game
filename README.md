# Family Feud Game

A tablet-optimized Family Feud game built with Flutter using responsive design principles.

## Features

- **Import Questions**: Add questions with up to 10 responses and point values
- **Questions List**: View all imported questions and select one to play
- **Game Board**: Interactive game board with the following features:
  - Hidden response placeholders (numbered 1-10)
  - Tap to reveal responses with their text and points
  - Red X counter button in the app bar
  - Animated X overlay that displays for 5 seconds
  - Error sound effect when X button is pressed
  - Back button to return to questions list
  - Automatic question reset when selected (resets X count to 0)
- **Responsive Design**: Optimized for tablets but works on all screen sizes

## How to Use

1. **Import Questions**:
   - Tap "Import Question" from the home screen
   - Enter your question text
   - Fill in up to 10 responses with their point values
   - Tap "Add Question" to save

2. **Play the Game**:
   - Tap "View Questions" from the home screen
   - Select a question to start playing
   - Tap on numbered placeholders to reveal responses
   - Use the X button in the app bar to mark wrong answers
   - The X overlay will show all current X's with animation and sound
   - Press the back button to return to the questions list

## Running the App

```bash
flutter pub get
flutter run
```

## Technical Details

- Built with Flutter 3.38.5
- Uses Provider for state management
- Implements responsive design with LayoutBuilder
- Features animations and sound effects for game feedback
