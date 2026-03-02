# Flutter Components

A collection of reusable Flutter UI components and widgets that can be easily integrated into your Flutter applications. Each component is ready to use with copy-paste implementation.

## 📦 Components

### 1. [Retro Splash Screen](./retro_spashscreen)

A customizable splash screen widget with retro aesthetic and smooth animations.

![Retro Splash Preview](./retro_spashscreen/retro_splash_screen.gif)

**Features:**
- Retro-style splash screen with typewriter effect
- Drawing/animation effects
- Easy to customize colors and timings
- Supports iOS and Android platforms

**Quick Setup:**
Simply copy the `splash_screen.dart` file to your project's `lib/screens/` directory and import it in your `main.dart`.

[📖 View Full Documentation](./retro_spashscreen/README.md)

---

### 2. [Animated Splash Screen](./animated_splashscreen)

An animated splash screen component with smooth fade and scale animations.

![Animated Splash Preview](./animated_splashscreen/animated_splash.gif)

**Features:**
- Smooth fade-in and scale animations
- Customizable duration and easing
- Easy to integrate into any Flutter app
- Works on all platforms

**Quick Setup:**
Copy the `splash_Screen.dart` file to your project and use it as your app's home screen.

[📖 View Full Documentation](./animated_splashscreen/README.md)

---

### 3. [Theme Mode Button](./ThemeMode_Button)

A theme switcher widget that allows users to toggle between light and dark themes.

**Features:**
- Easy-to-use theme toggle button
- Dark and light mode support
- Customizable styling
- Works with Flutter's built-in theming system

**Quick Setup:**
Copy the theme controller and button files to your project and integrate with your app's theme provider.

[📖 View Full Documentation](./ThemeMode_Button/README.md)

---

### 4. [Chat Encryption Module](./chat_encryption_module)

A complete, production-ready Flutter package for building end-to-end encrypted chat applications with Firebase and RSA encryption.

**Features:**
- 🔐 End-to-end RSA 2048-bit encryption
- 🔥 Firebase Firestore integration for real-time messaging
- 👥 Single and group chat support
- 🚫 User blocking functionality
- 🔍 Message search capability
- 📱 Read receipts and message tracking
- 🏗️ Clean architecture with Riverpod state management
- ✅ Production-tested code from real app

**Quick Setup:**

1. **Copy the module folder** to your project
2. **Add dependencies** from `pubspec.yaml`:
   ```yaml
   cloud_firestore: ^5.4.0
   firebase_auth: ^5.1.4
   crypton: ^2.0.0
   flutter_riverpod: ^2.6.0
   ```

3. **Initialize Firebase** in your app
4. **Generate user encryption keys**:
   ```dart
   import 'package:chat_encryption_module/chat_encryption_module.dart';
   
   // Generate keys for the current user
   final userCreds = UserCredentials.generate('user_123');
   // Store securely using flutter_secure_storage
   ```

5. **Import and use in your app**:
   ```dart
   import 'package:chat_encryption_module/chat_encryption_module.dart';
   
   // In your provider setup
   final encryptionService = ref.watch(encryptionServiceProvider);
   final chatRepository = ref.watch(chatRepositoryProvider);
   
   // Create encrypted chat room
   final room = await chatRepository.createChatRoom(
     chatRoomId: 'room_123',
     chatType: ChatType.single,
     members: ['user_1', 'user_2'],
     memberPublicKeys: {'user_1': 'public_key_1', 'user_2': 'public_key_2'},
   );
   
   // Send encrypted message
   final encrypted = encryptionService.encrypt(
     content: 'Hello!',
     publicKey: publicKeyFromString,
   );
   
   await chatRepository.sendMessage(
     chatRoomId: 'room_123',
     senderId: 'user_1',
     encryptedContent: encrypted,
     messageType: MessageType.text,
   );
   ```

6. **Use the provided UI screens** or build your own using the components

**Key Components:**
- `EncryptionService` - RSA encryption/decryption utilities
- `ChatRepository` - Firebase Firestore operations
- `ChatRoomController` & `MessageController` - State management with Riverpod
- `ChatListScreen`, `ChatScreen`, `CreateChatScreen` - Example UI

[📖 View Full Documentation](./chat_encryption_module/MODULE_GUIDE.md)

---

## 🚀 Getting Started

Each component is a standalone example that can be used independently:

1. **Clone or download** this repository
2. **Navigate** to the component folder you want to use
3. **Copy** the necessary files to your project
4. **Follow** the component's README for integration steps

## 📋 Requirements

- Flutter SDK: 3.0 or higher
- Dart SDK: 3.0 or higher

## 💡 Tips

- Each component is self-contained and can be used without any external package dependencies
- Feel free to customize and modify components to suit your needs
- Refer to individual component READMEs for detailed customization options

## 📄 License

All components are available under the MIT License. See individual LICENSE files for details.

## 🤝 Contributing

Feel free to contribute improvements, bug fixes, or new components! 

---

**Happy coding! 🎉**
