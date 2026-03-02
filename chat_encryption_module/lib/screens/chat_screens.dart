import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';
import '../providers/chat_providers.dart';

/// Main chat list screen showing all user's chat rooms
class ChatListScreen extends ConsumerWidget {
  final String userId;
  final Function(ChatRoom)? onChatSelected;

  const ChatListScreen({
    Key? key,
    this.userId = 'current_user', // Replace with actual user ID from auth
    this.onChatSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: chatRoomsAsync.when(
        data: (chatRooms) {
          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64),
                  const SizedBox(height: 16),
                  const Text('No chats yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateChatScreen(),
                        ),
                      );
                    },
                    child: const Text('Start a chat'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return ChatRoomTile(
                chatRoom: chatRoom,
                currentUserId: userId,
                onTap: () {
                  if (onChatSelected != null) {
                    onChatSelected!(chatRoom);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(chatRoom: chatRoom),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

/// Individual chat room tile for the list
class ChatRoomTile extends StatelessWidget {
  final ChatRoom chatRoom;
  final String currentUserId;
  final VoidCallback? onTap;

  const ChatRoomTile({
    Key? key,
    required this.chatRoom,
    required this.currentUserId,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otherUser = chatRoom.members.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Unknown',
    );

    return ListTile(
      title: Text(chatRoom.groupName ?? otherUser),
      subtitle: Text('${chatRoom.members.length} members'),
      leading: CircleAvatar(
        child: Text(
          (chatRoom.groupName ?? otherUser)[0].toUpperCase(),
        ),
      ),
      trailing: Text(
        _formatTime(chatRoom.updatedAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else {
      return '${diff.inDays}d';
    }
  }
}

/// Chat screen for viewing and sending messages
class ChatScreen extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;

  const ChatScreen({
    Key? key,
    required this.chatRoom,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late TextEditingController _messageController;
  late String _currentUserId = 'current_user'; // Replace with actual user ID

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageController = ref.read(messageControllerProvider.notifier);
    try {
      await messageController.sendMessage(
        chatRoomId: widget.chatRoom.chatRoomId,
        senderId: _currentUserId,
        plainTextContent: _messageController.text,
        chatRoomPublicKeyString: widget.chatRoom.publicKey,
        messageType: MessageType.text,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.chatRoom.chatRoomId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.groupName ?? 'Chat'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearChatDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      chatRoom: widget.chatRoom,
                      currentUserId: _currentUserId,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error loading messages: $error'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat'),
        content: const Text('Delete all messages? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final controller = ref.read(chatRoomControllerProvider.notifier);
              await controller.clearChat(widget.chatRoom.chatRoomId);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat cleared')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget
class MessageBubble extends ConsumerWidget {
  final ChatMessage message;
  final ChatRoom chatRoom;
  final String currentUserId;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.chatRoom,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the room's private key (would need to be decrypted with user's key)
    final isCurrentUser = message.senderId == currentUserId;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                message.senderId,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            // Note: In real implementation, decrypt message here
            Text(message.content),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.messageDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final time = timestamp.toDate();
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Screen to create new chat
class CreateChatScreen extends ConsumerStatefulWidget {
  const CreateChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends ConsumerState<CreateChatScreen> {
  late TextEditingController _recipientController;
  late TextEditingController _groupNameController;
  bool _isGroupChat = false;
  final List<String> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController();
    _groupNameController = TextEditingController();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _createChat() async {
    if (_isGroupChat && _groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    final members = _isGroupChat
        ? _selectedMembers
        : [_recipientController.text, 'current_user'];

    if (members.isEmpty || members.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid number of members')),
      );
      return;
    }

    try {
      // TODO: Get actual public keys for members
      final memberPublicKeys = {
        for (final member in members) member: 'public_key_placeholder',
      };

      final controller = ref.read(chatRoomControllerProvider.notifier);
      final chatRoom = await controller.createChatRoom(
        chatRoomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
        chatType: _isGroupChat ? ChatType.group : ChatType.single,
        members: members,
        memberPublicKeys: memberPublicKeys,
        groupName: _isGroupChat ? _groupNameController.text : null,
      );

      if (mounted) {
        Navigator.pop(context, chatRoom);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Group Chat'),
              value: _isGroupChat,
              onChanged: (value) {
                setState(() => _isGroupChat = value);
              },
            ),
            const SizedBox(height: 16),
            if (!_isGroupChat)
              TextField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Recipient ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            else ...[
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Add member ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_recipientController.text.isNotEmpty) {
                        setState(() {
                          _selectedMembers.add(_recipientController.text);
                          _recipientController.clear();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _selectedMembers
                    .map(
                      (member) => Chip(
                        label: Text(member),
                        onDeleted: () {
                          setState(() => _selectedMembers.remove(member));
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createChat,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Create Chat'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
