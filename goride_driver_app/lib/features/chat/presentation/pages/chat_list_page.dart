import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_driver_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:goride_driver_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>>? _cachedConversations;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatConversationsFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a0a0a),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "MESSAGES",
                        style: GoogleFonts.outfit(
                          color: const Color(0xff76eb07),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "Rider Chats",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatConversationsLoaded) {
                    setState(() {
                      _cachedConversations = state.conversations;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading && _cachedConversations == null) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xff76eb07)));
                  }
                  if (state is ChatError && _cachedConversations == null) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.outfit(color: Colors.redAccent),
                      ),
                    );
                  }
                  
                  final conversations = _cachedConversations ?? [];

                  if (state is ChatConversationsLoaded || _cachedConversations != null) {
                    if (conversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white24, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              "No past chats found",
                              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: const Color(0xff76eb07),
                      backgroundColor: const Color(0xff1a1a1a),
                      onRefresh: () async {
                        context.read<ChatBloc>().add(const ChatConversationsFetched());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          return _buildChatTile(context, conversations[index]);
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> conversation) {
    final String name = conversation['other_user_name'] ?? 'Unknown Rider';
    final String lastMessage = conversation['last_message'] ?? 'No messages';
    final DateTime lastTime = DateTime.parse(conversation['last_message_time']);
    final String otherUserId = conversation['other_user_id'];
    final bool isActive = conversation['is_active'] ?? false;
    final int unreadCount = conversation['unread_count'] ?? 0;
    final String? profilePic = conversation['profile_pic'] ?? conversation['profilePic'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              userName: name,
              tripId: "PAST CONVERSATION",
              userId: otherUserId,
              profilePic: profilePic,
            ),
          ),
        ).then((_) {
          if (mounted) {
            context.read<ChatBloc>().add(const ChatConversationsFetched(silent: true));
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xff252525),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    image: profilePic != null && profilePic.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profilePic),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profilePic == null || profilePic.isEmpty
                      ? const Icon(Icons.person_rounded, color: Color(0xff76eb07), size: 32)
                      : null,
                ),
                if (isActive)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xff76eb07),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xff1a1a1a), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _formatTime(lastTime),
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: GoogleFonts.outfit(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xff76eb07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return DateFormat('hh:mm a').format(time);
    if (diff.inDays < 7) return DateFormat('EEEE').format(time);
    return DateFormat('dd/MM/yy').format(time);
  }
}
