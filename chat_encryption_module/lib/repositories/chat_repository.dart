import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../services/encryption_service.dart';

/// Repository for managing chat operations with Firebase Firestore
class ChatRepository {
  final FirebaseFirestore _firestore;
  final EncryptionService _encryptionService;

  ChatRepository({
    FirebaseFirestore? firestore,
    EncryptionService? encryptionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _encryptionService = encryptionService ?? EncryptionService();

  static const String _chatRoomsCollection = 'chatRooms';
  static const String _messagesSubCollection = 'messages';

  /// Create a new chat room with encrypted keys
  ///
  /// Parameters:
  ///   - [chatRoomId]: Unique ID for the chat room
  ///   - [chatType]: Type of chat (single or group)
  ///   - [members]: List of user IDs in the chat
  ///   - [memberPublicKeys]: Map of userId to their public key string
  ///   - [groupName]: Optional name for group chats
  ///
  /// Returns: The created [ChatRoom]
  Future<ChatRoom> createChatRoom({
    required String chatRoomId,
    required ChatType chatType,
    required List<String> members,
    required Map<String, String> memberPublicKeys,
    String? groupName,
  }) async {
    // Generate room encryption keys
    final roomKeyPair = _encryptionService.generateKeyPair();
    final roomPublicKeyString = roomKeyPair.publicKey.toString();
    final roomPrivateKeyString = roomKeyPair.privateKey.toString();

    // Create encryption keys for each member
    final encryptionKeys = <EncryptionKey>[];
    for (final memberId in members) {
      final memberPublicKeyString = memberPublicKeys[memberId];
      if (memberPublicKeyString != null) {
        // Encrypt the room private key with each member's public key
        final encryptedPrivateKey = _encryptionService.encryptWithStringKey(
          content: roomPrivateKeyString,
          publicKeyString: memberPublicKeyString,
        );

        encryptionKeys.add(
          EncryptionKey(
            userId: memberId,
            encryptedPrivateKey: encryptedPrivateKey,
          ),
        );
      }
    }

    final now = Timestamp.now();
    final chatRoom = ChatRoom(
      chatRoomId: chatRoomId,
      chatType: chatType,
      members: members,
      encryptionKeys: encryptionKeys,
      publicKey: roomPublicKeyString,
      blockedUsers: {},
      groupName: groupName,
      createdAt: now,
      updatedAt: now,
    );

    // Save to Firestore
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .set(chatRoom.toJson());

    return chatRoom;
  }

  /// Get a specific chat room
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    final doc =
        await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).get();

    if (!doc.exists) return null;
    return ChatRoom.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Get all chat rooms for a user
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    final snapshot = await _firestore
        .collection(_chatRoomsCollection)
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) => ChatRoom.fromJson(doc.data())).toList();
  }

  /// Get chat rooms stream for real-time updates
  Stream<List<ChatRoom>> getChatRoomsStream(String userId) {
    return _firestore
        .collection(_chatRoomsCollection)
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromJson(doc.data())).toList());
  }

  /// Send an encrypted message
  ///
  /// Parameters:
  ///   - [chatRoomId]: ID of the chat room
  ///   - [senderId]: ID of the user sending the message
  ///   - [encryptedContent]: Pre-encrypted message content
  ///   - [messageType]: Type of message
  ///
  /// Returns: The created [ChatMessage]
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String encryptedContent,
    required MessageType messageType,
  }) async {
    final messageId = const Uuid().v4();
    final now = Timestamp.now();

    final message = ChatMessage(
      messageId: messageId,
      chatRoomId: chatRoomId,
      senderId: senderId,
      content: encryptedContent,
      type: messageType,
      seenMap: {senderId: now.millisecondsSinceEpoch},
      messageDate: now,
    );

    // Save message
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesSubCollection)
        .doc(messageId)
        .set(message.toJson());

    // Update chat room's updatedAt
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .update({'updatedAt': now});

    return message;
  }

  /// Get messages for a chat room
  ///
  /// Filters out messages from blocked users.
  Future<List<ChatMessage>> getMessages({
    required String chatRoomId,
    required Set<String> blockedUsers,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesSubCollection)
        .orderBy('messageDate', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromJson(doc.data()))
        .where((msg) => !blockedUsers.contains(msg.senderId))
        .toList();
  }

  /// Get messages stream for real-time updates
  ///
  /// Filters out messages from blocked users.
  Stream<List<ChatMessage>> getMessagesStream({
    required String chatRoomId,
    required Set<String> blockedUsers,
    int limit = 100,
  }) {
    return _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesSubCollection)
        .orderBy('messageDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data()))
            .where((msg) => !blockedUsers.contains(msg.senderId))
            .toList());
  }

  /// Mark a message as seen by a user
  Future<void> markMessageAsSeen({
    required String chatRoomId,
    required String messageId,
    required String userId,
  }) async {
    final now = Timestamp.now();
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesSubCollection)
        .doc(messageId)
        .update({
      'seenMap.$userId': now.millisecondsSinceEpoch,
    });
  }

  /// Block a user in a chat room
  Future<void> blockUser({
    required String chatRoomId,
    required String blockedUserId,
  }) async {
    await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });
  }

  /// Unblock a user in a chat room
  Future<void> unblockUser({
    required String chatRoomId,
    required String unblockedUserId,
  }) async {
    await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).update({
      'blockedUsers': FieldValue.arrayRemove([unblockedUserId]),
    });
  }

  /// Get blocked users for a chat room
  Future<Set<String>> getBlockedUsers(String chatRoomId) async {
    final chatRoom = await getChatRoom(chatRoomId);
    return chatRoom?.blockedUsers ?? {};
  }

  /// Search messages in a chat room (decryption required client-side)
  ///
  /// This returns messages that match the search query after decryption.
  /// The actual decryption should be done in the application layer.
  Future<List<ChatMessage>> searchMessages({
    required String chatRoomId,
    required String query,
    required Function(String) decryptMessage,
  }) async {
    final allMessages = await getMessages(
      chatRoomId: chatRoomId,
      blockedUsers: {},
    );

    final results = <ChatMessage>[];
    for (final message in allMessages) {
      try {
        final decrypted = decryptMessage(message.content);
        if (decrypted.toLowerCase().contains(query.toLowerCase())) {
          results.add(message);
        }
      } catch (e) {
        // Skip messages that fail to decrypt
        continue;
      }
    }

    return results;
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesSubCollection)
        .doc(messageId)
        .delete();
  }

  /// Clear all messages in a chat room
  Future<void> clearChat(String chatRoomId) async {
    final messages = await getMessages(
      chatRoomId: chatRoomId,
      blockedUsers: {},
      limit: 1000,
    );

    for (final message in messages) {
      await deleteMessage(chatRoomId: chatRoomId, messageId: message.messageId);
    }
  }
}
