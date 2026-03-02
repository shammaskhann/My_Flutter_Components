import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../repositories/chat_repository.dart';
import '../services/encryption_service.dart';

// Service and Repository Providers
final encryptionServiceProvider = Provider((ref) => EncryptionService());

final chatRepositoryProvider = Provider((ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  return ChatRepository(encryptionService: encryptionService);
});

// Stream Providers
final chatRoomsStreamProvider = StreamProvider.family<List<ChatRoom>, String>(
  (ref, userId) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return chatRepository.getChatRoomsStream(userId);
  },
);

final messagesStreamProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, chatRoomId) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return chatRepository.getMessagesStream(
      chatRoomId: chatRoomId,
      blockedUsers: {},
    );
  },
);

final chatRoomProvider = FutureProvider.family<ChatRoom?, String>(
  (ref, chatRoomId) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return chatRepository.getChatRoom(chatRoomId);
  },
);

// Chat Room State Notifier
class ChatRoomController extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _chatRepository;
  final EncryptionService _encryptionService;

  ChatRoomController({
    required ChatRepository chatRepository,
    required EncryptionService encryptionService,
  })  : _chatRepository = chatRepository,
        _encryptionService = encryptionService,
        super(const AsyncValue.data(null));

  Future<ChatRoom> createChatRoom({
    required String chatRoomId,
    required ChatType chatType,
    required List<String> members,
    required Map<String, String> memberPublicKeys,
    String? groupName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final room = await _chatRepository.createChatRoom(
        chatRoomId: chatRoomId,
        chatType: chatType,
        members: members,
        memberPublicKeys: memberPublicKeys,
        groupName: groupName,
      );
      state = const AsyncValue.data(null);
      return room;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> blockUser({
    required String chatRoomId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _chatRepository.blockUser(
        chatRoomId: chatRoomId,
        blockedUserId: userId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> unblockUser({
    required String chatRoomId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _chatRepository.unblockUser(
        chatRoomId: chatRoomId,
        unblockedUserId: userId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> clearChat(String chatRoomId) async {
    state = const AsyncValue.loading();
    try {
      await _chatRepository.clearChat(chatRoomId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final chatRoomControllerProvider =
    StateNotifierProvider<ChatRoomController, AsyncValue<void>>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return ChatRoomController(
    chatRepository: chatRepository,
    encryptionService: encryptionService,
  );
});

// Message State Notifier
class MessageController extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _chatRepository;
  final EncryptionService _encryptionService;

  MessageController({
    required ChatRepository chatRepository,
    required EncryptionService encryptionService,
  })  : _chatRepository = chatRepository,
        _encryptionService = encryptionService,
        super(const AsyncValue.data(null));

  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String plainTextContent,
    required String chatRoomPublicKeyString,
    required MessageType messageType,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Encrypt the message
      final encryptedContent = _encryptionService.encryptWithStringKey(
        content: plainTextContent,
        publicKeyString: chatRoomPublicKeyString,
      );

      final message = await _chatRepository.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        encryptedContent: encryptedContent,
        messageType: messageType,
      );

      state = const AsyncValue.data(null);
      return message;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> markMessageAsSeen({
    required String chatRoomId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _chatRepository.markMessageAsSeen(
        chatRoomId: chatRoomId,
        messageId: messageId,
        userId: userId,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  String decryptMessage({
    required String encryptedContent,
    required String chatRoomPrivateKeyString,
  }) {
    return _encryptionService.decryptWithStringKey(
      content: encryptedContent,
      privateKeyString: chatRoomPrivateKeyString,
    );
  }

  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _chatRepository.deleteMessage(
        chatRoomId: chatRoomId,
        messageId: messageId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final messageControllerProvider =
    StateNotifierProvider<MessageController, AsyncValue<void>>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return MessageController(
    chatRepository: chatRepository,
    encryptionService: encryptionService,
  );
});

// Search State Notifier
class SearchController extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatRepository _chatRepository;
  final EncryptionService _encryptionService;

  SearchController({
    required ChatRepository chatRepository,
    required EncryptionService encryptionService,
  })  : _chatRepository = chatRepository,
        _encryptionService = encryptionService,
        super(const AsyncValue.data([]));

  Future<void> searchMessages({
    required String chatRoomId,
    required String query,
    required String chatRoomPrivateKeyString,
  }) async {
    state = const AsyncValue.loading();
    try {
      final results = await _chatRepository.searchMessages(
        chatRoomId: chatRoomId,
        query: query,
        decryptMessage: (encrypted) {
          return _encryptionService.decryptWithStringKey(
            content: encrypted,
            privateKeyString: chatRoomPrivateKeyString,
          );
        },
      );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, AsyncValue<List<ChatMessage>>>(
  (ref) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    final encryptionService = ref.watch(encryptionServiceProvider);
    return SearchController(
      chatRepository: chatRepository,
      encryptionService: encryptionService,
    );
  },
);
