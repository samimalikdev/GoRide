import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:goride_app/features/chat/presentation/pages/chat_detail_page.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Messages",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatConversationsLoaded) {
            setState(() {
              _cachedConversations = state.conversations;
            });
          }
        },
        builder: (context, state) {
          if (state is ChatLoading && _cachedConversations == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatError && _cachedConversations == null) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          
          final conversations = _cachedConversations ?? [];

          if (state is ChatConversationsLoaded || _cachedConversations != null) {
            if (conversations.isEmpty) {
              return Center(
                child: Text(
                  "No past chats found",
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return _buildChatTile(context, conversations[index]);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> conversation) {
    final String name = conversation['other_user_name'] ?? 'Unknown User';
    final String lastMessage = conversation['last_message'] ?? 'No messages';
    final DateTime lastTime = DateTime.parse(conversation['last_message_time']);
    final String otherUserId = conversation['other_user_id'];
    
    final String vehicle = conversation['vehicle_info'] ?? 'Past Conversation';
    final bool isActive = conversation['is_active'] ?? false;
    final String? profilePic = conversation['profile_pic'] ?? conversation['profilePic'];
    
    final timeStr = _formatTime(lastTime);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              userName: name,
              vehicle: vehicle,
              receiverId: otherUserId,
              isReadOnly: !isActive,
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xff252525),
                    borderRadius: BorderRadius.circular(15),
                    image: profilePic != null && profilePic.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profilePic),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profilePic == null || profilePic.isEmpty
                      ? Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
                if (conversation['unread_count'] > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
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
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xff76eb07).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? const Color(0xff76eb07).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          isActive ? "ACTIVE" : "COMPLETED",
                          style: GoogleFonts.poppins(
                            color: isActive ? const Color(0xff76eb07) : Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 11,
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
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inDays < 1) return DateFormat('hh:mm a').format(time);
    if (diff.inDays < 7) return DateFormat('EEEE').format(time);
    return DateFormat('dd/MM/yyyy').format(time);
  }
}

