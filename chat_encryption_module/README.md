# Chat Encryption Module

A complete, production-ready Flutter package for building end-to-end encrypted chat applications with Firebase and RSA encryption.

## 🎯 Features

✅ **End-to-End Encryption** - RSA 2048-bit encryption for all messages  
✅ **Firebase Integration** - Real-time messaging with Firestore  
✅ **Flexible Chat Types** - Single and group chat support  
✅ **User Blocking** - Block users from messaging  
✅ **Message Search** - Search through encrypted messages  
✅ **Read Receipts** - Track who has read messages  
✅ **State Management** - Riverpod for reactive UI updates  
✅ **Production-Ready** - Tested code from real applications  

## 📋 Requirements

- Flutter SDK: 3.0 or higher
- Dart SDK: 3.0 or higher
- Firebase project setup (Authentication & Firestore)

## 🚀 Quick Start

### 1. Add Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.29.0
  cloud_firestore: ^5.4.0
  firebase_auth: ^5.1.4
  crypton: ^2.0.0
  uuid: ^4.0.0
  flutter_riverpod: ^2.6.0
  intl: ^0.19.0
```

### 2. Initialize Firebase

In your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 3. Generate User Encryption Keys

```dart
import 'package:chat_encryption_module/chat_encryption_module.dart';

// Generate keys for user
final userCreds = UserCredentials.generate('user_123');

// Store securely (use flutter_secure_storage in production)
await ChatInitializer.storeUserCredentials(userCreds);
```

### 4. Create Your First Chat Room

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_encryption_module/chat_encryption_module.dart';

void createChat(WidgetRef ref) async {
  final chatRoomController = ref.read(chatRoomControllerProvider.notifier);
  
  // Create a new chat room
  final chatRoom = await chatRoomController.createChatRoom(
    chatRoomId: 'unique_room_id',
    chatType: ChatType.single,
    members: ['current_user_id', 'other_user_id'],
    memberPublicKeys: {
      'current_user_id': 'current_user_public_key',
      'other_user_id': 'other_user_public_key',
    },
  );
}
```

### 5. Send an Encrypted Message

```dart
void sendMessage(WidgetRef ref) async {
  final encryptionService = ref.read(encryptionServiceProvider);
  final messageController = ref.read(messageControllerProvider.notifier);
  final chatRepository = ref.read(chatRepositoryProvider);
  
  // Get the chat room's public key
  final chatRoom = await chatRepository.getChatRoom('room_id');
  final publicKey = encryptionService.stringToPublicKey(chatRoom!.publicKey);
  
  // Encrypt the message
  final encrypted = encryptionService.encrypt(
    content: 'Hello World!',
    publicKey: publicKey,
  );
  
  // Send encrypted message
  await messageController.sendMessage(
    chatRoomId: 'room_id',
    senderId: 'user_123',
    encryptedContent: encrypted,
    messageType: MessageType.text,
  );
}
```

### 6. Decrypt and Display Messages

```dart
void displayMessages(WidgetRef ref) {
  final messagesAsync = ref.watch(messagesStreamProvider('room_id'));
  
  return messagesAsync.when(
    data: (messages) {
      return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          
          // Decrypt message using your private key
          final encryptionService = ref.read(encryptionServiceProvider);
          final privateKey = encryptionService.stringToPrivateKey(
            'your_private_key_string'
          );
          
          final decrypted = encryptionService.decrypt(
            content: message.content,
            privateKey: privateKey,
          );
          
          return MessageBubble(
            message: decrypted,
            isOwn: message.senderId == 'current_user_id',
          );
        },
      );
    },
    loading: () => const CircularProgressIndicator(),
    error: (error, stackTrace) => Text('Error: $error'),
  );
}
```

## 📁 Module Structure

```
chat_encryption_module/
├── lib/
│   ├── chat_encryption_module.dart      # Main exports
│   ├── models/                          # Data models
│   │   └── chat_models.dart
│   ├── services/                        # RSA encryption
│   │   └── encryption_service.dart
│   ├── repositories/                    # Firebase operations
│   │   └── chat_repository.dart
│   ├── providers/                       # Riverpod state management
│   │   └── chat_providers.dart
│   ├── screens/                         # Example UI screens
│   │   └── chat_screens.dart
│   └── utils/                           # Utilities
│       └── chat_utils.dart
├── pubspec.yaml
├── README.md
└── MODULE_GUIDE.md
```

## 🔐 How Encryption Works

### Key Generation
- Each user gets a unique RSA key pair (public + private)
- Each chat room gets its own RSA key pair
- The chat room's private key is encrypted with each member's public key

### Message Encryption Flow
1. User encrypts message with chat room's public key
2. Encrypted message is stored in Firestore
3. Only members with the chat room's private key can decrypt

### Message Decryption Flow
1. Retrieve encrypted message from Firestore
2. Use your stored private key to decrypt the chat room's private key
3. Use the chat room's private key to decrypt the message

## 🛠️ Customization

### Modify Data Models
Edit `lib/models/chat_models.dart` to add custom fields:

```dart
class ChatMessage {
  // Add your custom fields here
  final String? replyToMessageId;
  final List<String>? reactions;
  // ...
}
```

### Add Custom Screens
Create new screens in `lib/screens/` and export them in `chat_encryption_module.dart`:

```dart
export 'screens/chat_screens.dart'
    show
        ChatListScreen,
        ChatScreen,
        YourCustomScreen; // Add your custom screen
```

### Use Different Encryption Provider
Extend `EncryptionService` to use a different encryption algorithm:

```dart
class CustomEncryptionService extends EncryptionService {
  @override
  String encrypt({required String content, required RSAPublicKey publicKey}) {
    // Your custom encryption logic
    return super.encrypt(content: content, publicKey: publicKey);
  }
}
```

## 📱 Firebase Firestore Setup

### Required Collections

**`chatRooms`** - Stores all chat rooms
```
chatRooms/
  ├── chatRoomId1/
  │   ├── chatType: "single"
  │   ├── members: ["user1", "user2"]
  │   ├── encryptionKeys: [...]
  │   ├── publicKey: "..."
  │   └── messages/ (subcollection)
  │       ├── messageId1: {...}
  │       └── messageId2: {...}
```

### Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /chatRooms/{chatRoomId} {
      allow read, write: if request.auth.uid in resource.data.members;
      
      match /messages/{messageId} {
        allow read, write: if request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(chatRoomId)).data.members;
      }
    }
  }
}
```

## 🔒 Security Best Practices

1. **Store Private Keys Securely**
   - Use `flutter_secure_storage` for encrypted local storage
   - Never hardcode keys in your app
   - Consider using device-specific encryption

2. **Firebase Auth**
   - Implement proper authentication
   - Validate user identity before creating chat rooms
   - Use custom claims for authorization

3. **Key Management**
   - Regenerate keys periodically
   - Implement key rotation mechanism
   - Have backup/recovery procedures

4. **Message Validation**
   - Validate encrypted content size
   - Implement rate limiting
   - Check sender authorization

## 🧪 Testing

### Unit Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_encryption_module/chat_encryption_module.dart';

void main() {
  test('Encryption and Decryption', () {
    final service = EncryptionService();
    final keyPair = service.generateKeyPair();
    
    const message = 'Test Message';
    final encrypted = service.encrypt(
      content: message,
      publicKey: keyPair.publicKey,
    );
    
    final decrypted = service.decrypt(
      content: encrypted,
      privateKey: keyPair.privateKey,
    );
    
    expect(decrypted, equals(message));
  });
}
```

## 📚 Advanced Usage

### Real-Time Chat with Read Receipts
```dart
// Watch messages in real-time
final messagesAsync = ref.watch(messagesStreamProvider('room_id'));

// Update read receipt when user sees message
await chatRepository.markAsRead(
  chatRoomId: 'room_id',
  messageId: 'msg_id',
  userId: 'user_123',
);
```

### Message Search
```dart
// Search for specific messages
final results = await chatRepository.searchMessages(
  chatRoomId: 'room_id',
  searchTerm: 'hello',
);
```

### Block User
```dart
// Block a user from the chat room
await chatRepository.blockUser(
  chatRoomId: 'room_id',
  userId: 'blocked_user_id',
);
```

## 🐛 Troubleshooting

**Issue:** Decryption fails
- Ensure you're using the correct private key
- Verify the private key hasn't been corrupted
- Check that the key pair is valid

**Issue:** Messages not appearing
- Check Firebase Firestore rules
- Verify user is a member of the chat room
- Check network connectivity

**Issue:** Slow encryption/decryption
- Large messages may take time to process
- Consider splitting large messages
- Use message pagination

## 📖 More Documentation

- [MODULE_GUIDE.md](./MODULE_GUIDE.md) - Complete architecture and structure
- [Flutter Riverpod Docs](https://riverpod.dev) - State management
- [Crypton Package](https://pub.dev/packages/crypton) - Encryption details
- [Firebase Docs](https://firebase.google.com/docs) - Firebase setup

## 📝 License

This module is available under the MIT License.

## 🤝 Support

For issues, questions, or improvements, please refer to the main repository.
