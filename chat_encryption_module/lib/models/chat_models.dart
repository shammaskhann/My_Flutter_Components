import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeration for different message types
enum MessageType { text, image, audio, video, file }

/// Enumeration for chat types
enum ChatType { single, group }

/// Represents an encryption key stored in a chat room
///
/// Each user has their own encrypted copy of the chat room's private key.
/// The private key is encrypted with the user's own public key.
class EncryptionKey {
  final String userId;
  final String encryptedPrivateKey;

  EncryptionKey({
    required this.userId,
    required this.encryptedPrivateKey,
  });

  factory EncryptionKey.fromJson(Map<String, dynamic> json) {
    return EncryptionKey(
      userId: json['userId'] as String,
      encryptedPrivateKey: json['encryptedPrivateKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'encryptedPrivateKey': encryptedPrivateKey,
    };
  }

  EncryptionKey copyWith({
    String? userId,
    String? encryptedPrivateKey,
  }) {
    return EncryptionKey(
      userId: userId ?? this.userId,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
    );
  }
}

/// Represents a single message in a chat room
class ChatMessage {
  final String messageId;
  final String chatRoomId;
  final String senderId;
  final String content; // Encrypted content
  final MessageType type;
  final Map<String, dynamic> seenMap; // userId -> timestamp of when they saw it
  final Timestamp messageDate;

  ChatMessage({
    required this.messageId,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.seenMap,
    required this.messageDate,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as String,
      chatRoomId: json['chatRoomId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values[json['type'] as int? ?? 0],
      seenMap: Map<String, dynamic>.from(json['seenMap'] as Map? ?? {}),
      messageDate: json['messageDate'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'type': type.index,
      'seenMap': seenMap,
      'messageDate': messageDate,
    };
  }

  ChatMessage copyWith({
    String? messageId,
    String? chatRoomId,
    String? senderId,
    String? content,
    MessageType? type,
    Map<String, dynamic>? seenMap,
    Timestamp? messageDate,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      seenMap: seenMap ?? this.seenMap,
      messageDate: messageDate ?? this.messageDate,
    );
  }

  @override
  String toString() => 'ChatMessage(id: $messageId, from: $senderId)';
}

/// Represents a chat room with encryption capabilities
class ChatRoom {
  final String chatRoomId;
  final ChatType chatType;
  final List<String> members;
  final List<EncryptionKey> encryptionKeys;
  final String publicKey; // Public key for the chat room
  final Set<String> blockedUsers;
  final String? groupName;
  final String? groupImage;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ChatRoom({
    required this.chatRoomId,
    required this.chatType,
    required this.members,
    required this.encryptionKeys,
    required this.publicKey,
    required this.blockedUsers,
    this.groupName,
    this.groupImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomId: json['chatRoomId'] as String,
      chatType: ChatType.values[json['chatType'] as int? ?? 0],
      members: List<String>.from(json['members'] as List? ?? []),
      encryptionKeys: (json['encryptionKeys'] as List? ?? [])
          .map((e) => EncryptionKey.fromJson(e as Map<String, dynamic>))
          .toList(),
      publicKey: json['publicKey'] as String,
      blockedUsers: Set<String>.from(json['blockedUsers'] as List? ?? []),
      groupName: json['groupName'] as String?,
      groupImage: json['groupImage'] as String?,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: json['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'chatType': chatType.index,
      'members': members,
      'encryptionKeys': encryptionKeys.map((e) => e.toJson()).toList(),
      'publicKey': publicKey,
      'blockedUsers': blockedUsers.toList(),
      'groupName': groupName,
      'groupImage': groupImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ChatRoom copyWith({
    String? chatRoomId,
    ChatType? chatType,
    List<String>? members,
    List<EncryptionKey>? encryptionKeys,
    String? publicKey,
    Set<String>? blockedUsers,
    String? groupName,
    String? groupImage,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ChatRoom(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      chatType: chatType ?? this.chatType,
      members: members ?? this.members,
      encryptionKeys: encryptionKeys ?? this.encryptionKeys,
      publicKey: publicKey ?? this.publicKey,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      groupName: groupName ?? this.groupName,
      groupImage: groupImage ?? this.groupImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ChatRoom(id: $chatRoomId, members: ${members.length})';
}
