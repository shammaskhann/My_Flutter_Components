import 'package:crypton/crypton.dart';
import '../services/encryption_service.dart';

/// User credentials including encryption keys
class UserCredentials {
  final String userId;
  final String publicKeyString;
  final String privateKeyString;

  UserCredentials({
    required this.userId,
    required this.publicKeyString,
    required this.privateKeyString,
  });

  /// Generate new user credentials with RSA keys
  static UserCredentials generate(String userId) {
    final encryptionService = EncryptionService();
    final keyPair = encryptionService.generateKeyPair();

    return UserCredentials(
      userId: userId,
      publicKeyString: keyPair.publicKey.toString(),
      privateKeyString: keyPair.privateKey.toString(),
    );
  }

  /// Convert to JSON for storage
  Map<String, String> toJson() {
    return {
      'userId': userId,
      'publicKeyString': publicKeyString,
      'privateKeyString': privateKeyString,
    };
  }

  /// Create from JSON
  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      userId: json['userId'] as String,
      publicKeyString: json['publicKeyString'] as String,
      privateKeyString: json['privateKeyString'] as String,
    );
  }
}

/// Helper class for chat initialization
class ChatInitializer {
  /// Initialize user encryption credentials
  ///
  /// Generates new RSA keys for the user if they don't exist.
  static UserCredentials initializeUserEncryption(String userId) {
    return UserCredentials.generate(userId);
  }

  /// Store user credentials securely (should be implemented with secure storage)
  ///
  /// In production, use flutter_secure_storage or similar.
  static Future<void> storeUserCredentials(UserCredentials credentials) async {
    // TODO: Implement secure storage
    // Example with flutter_secure_storage:
    // await _secureStorage.write(
    //   key: 'user_credentials_${credentials.userId}',
    //   value: jsonEncode(credentials.toJson()),
    // );
  }

  /// Retrieve stored user credentials
  ///
  /// Returns null if not found.
  static Future<UserCredentials?> getUserCredentials(String userId) async {
    // TODO: Implement secure retrieval
    // Example with flutter_secure_storage:
    // final stored = await _secureStorage.read(
    //   key: 'user_credentials_$userId',
    // );
    // if (stored == null) return null;
    // return UserCredentials.fromJson(jsonDecode(stored));
    return null;
  }
}

/// Validator for chat operations
class ChatValidator {
  /// Validate message content is not empty
  static bool validateMessageContent(String content) {
    return content.trim().isNotEmpty && content.trim().length <= 5000;
  }

  /// Validate chat room members
  static bool validateMembers(List<String> members) {
    return members.isNotEmpty && members.length <= 500;
  }

  /// Validate encryption key
  static bool validateEncryptionKey(String keyString) {
    final encryptionService = EncryptionService();
    return encryptionService.isValidPublicKey(keyString) ||
        encryptionService.isValidPrivateKey(keyString);
  }

  /// Validate user ID format
  static bool validateUserId(String userId) {
    return userId.isNotEmpty && userId.length >= 3 && userId.length <= 128;
  }

  /// Validate group name for chats
  static bool validateGroupName(String groupName) {
    return groupName.isNotEmpty && groupName.length <= 100;
  }
}

/// Constants for chat configuration
class ChatConstants {
  static const String chatRoomsCollection = 'chatRooms';
  static const String messagesSubCollection = 'messages';
  static const int maxMessageLength = 5000;
  static const int maxGroupNameLength = 100;
  static const int maxGroupMembers = 500;
  static const Duration messageReadTimeout = Duration(seconds: 30);
  static const Duration encryptionKeyExpiry = Duration(days: 365);
}
