import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../widgets/common/common_widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int orderId;
  final String target; // 'pharmacy' or 'customer'
  final String title;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.target,
    required this.title,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh messages every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      ref.invalidate(chatMessagesProvider((orderId: widget.orderId, target: widget.target)));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _controller.text;
    if (content.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(
          widget.orderId,
          content,
          widget.target,
        );
    _controller.clear();
    // Optimistic UI update or scroll to bottom could happen here
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // List is reversed, so 0 is bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the specific message stream for this order/target
    final messagesAsync = ref.watch(
        chatMessagesProvider((orderId: widget.orderId, target: widget.target)));
    
    // Also watch the general chat provider for loading state when sending
    final chatState = ref.watch(chatProvider);
    final isSending = chatState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              widget.target == 'pharmacy' ? 'Pharmacie' : 'Client', 
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                   return const AppEmptyWidget(
                     icon: Icons.chat_bubble_outline,
                     message: 'Aucun message',
                   );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.isMe; 
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue.shade600 : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(msg.createdAt),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const AppLoadingWidget(),
              error: (e, st) => AppErrorWidget(message: e.toString()),
            ),
          ),
          
          // Input Area
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
               color: Colors.white,
               boxShadow: [
                 BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
               ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !isSending,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: isSending ? null : _sendMessage,
                  backgroundColor: isSending ? Colors.grey : Colors.blue.shade600,
                  elevation: 2,
                  child: isSending 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
