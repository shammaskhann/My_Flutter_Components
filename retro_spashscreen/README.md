# retro_spashscreen

# Retro Splash Screen

## Overview
The Retro Splash Screen is a customizable splash screen widget for Flutter applications that provides a retro aesthetic with typewriter and drawing animations. Simply copy the code into your project to get started!

## Features
- Retro-style splash screen with animations
- Typewriter text effect
- Drawing/animation effects
- Easy to customize colors and timings
- Supports both iOS and Android platforms

## Setup Instructions

### 1. Copy the Splash Screen Code
Copy the `splash_screen.dart` file from this project to your Flutter application's `lib/screens/` directory (create the directory if it doesn't exist).

The splash screen file contains the `SplashScreen` widget with all the retro animations and styling.

### 2. Update Your Main App File
In your `lib/main.dart`, import and use the splash screen:

```dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Use the splash screen as home
    );
  }
}
```

### 3. (Optional) Add Assets
If you want to add custom assets or fonts, place them in your `assets/` directory and update your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/
```

## Customization

You can customize the splash screen by modifying the following in `splash_screen.dart`:

- **Colors**: Change the background color and text colors
- **Animation Durations**: Adjust the timing of animations by modifying the `Duration` values in `AnimationController`
- **Text Content**: Edit the text displayed in the splash screen
- **Styling**: Modify the fonts, sizes, and styling in the build method

## Usage Example

Once set up, the splash screen will automatically display when your app launches. After the animations complete, you can navigate to your main app screen:

```dart
// In your splash_screen.dart, after animations complete:
Future.delayed(const Duration(seconds: 3), () {
  if (mounted) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
});
```

## Demo
![Retro Splash Screen Demo](assets/demo.gif)

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
