/// Chat Encryption Module
///
/// A complete, production-ready Flutter package for building end-to-end
/// encrypted chat applications with Firebase and RSA encryption.
///
/// Main exports for the module:

// Models
export 'models/chat_models.dart'
    show ChatMessage, ChatRoom, EncryptionKey, MessageType, ChatType;

// Services
export 'services/encryption_service.dart' show EncryptionService;

// Repositories
export 'repositories/chat_repository.dart' show ChatRepository;

// Providers (Riverpod)
export 'providers/chat_providers.dart'
    show
        encryptionServiceProvider,
        chatRepositoryProvider,
        chatRoomsStreamProvider,
        messagesStreamProvider,
        chatRoomProvider,
        ChatRoomController,
        chatRoomControllerProvider,
        MessageController,
        messageControllerProvider,
        SearchController,
        searchControllerProvider;

// Screens
export 'screens/chat_screens.dart'
    show
        ChatListScreen,
        ChatScreen,
        CreateChatScreen,
        ChatRoomTile,
        MessageBubble;

// Utils
export 'utils/chat_utils.dart'
    show UserCredentials, ChatInitializer, ChatValidator, ChatConstants;
