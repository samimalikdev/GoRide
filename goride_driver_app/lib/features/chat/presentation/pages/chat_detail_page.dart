import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_driver_app/features/call/presentation/pages/call_page.dart';
import 'package:goride_driver_app/features/call/presentation/bloc/call_bloc.dart';
import 'package:goride_driver_app/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_state.dart';
import 'package:goride_driver_app/features/chat/presentation/bloc/chat_bloc.dart';

class ChatDetailPage extends StatefulWidget {
  final String userName;
  final String tripId;
  final String userId;
  final String? profilePic;

  const ChatDetailPage({
    super.key,
    required this.userName,
    required this.tripId,
    required this.userId,
    this.profilePic,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    print("CHAT_DETAIL (DRIVER): Initializing with target userId: ${widget.userId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(ChatHistoryFetched(widget.userId));
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _isPopping = false;

  void _handlePop() async {
    if (_isPopping) return;
    
    setState(() {
      _isPopping = true;
    });

    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handlePop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0a0a0a),
        appBar: _buildAppBar(context, true),
        body: Column(
          children: [
            _buildTripBanner(),
            _buildMessageList(),
            if (!_isPopping) _buildInputSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isAllowed) {
    return AppBar(
      backgroundColor: const Color(0xff121212),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: _handlePop,
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xff252525),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
              image: widget.profilePic != null && widget.profilePic!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.profilePic!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.profilePic == null || widget.profilePic!.isEmpty
                ? const Icon(Icons.person_rounded, color: Color(0xff76eb07), size: 24)
                : null,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                "Online",
                style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call_rounded, color: isAllowed ? const Color(0xff76eb07) : Colors.white24, size: 22),
          onPressed: !isAllowed ? null : () {
            sl<CallBloc>().add(StartCallEvent(widget.userId, name: widget.userName));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CallPage()),
            );
          },
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _buildTripBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xff76eb07).withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_rounded, color: Color(0xff76eb07), size: 14),
          const SizedBox(width: 8),
          Text(
            "ACTIVE TRIP: ${widget.tripId}",
            style: GoogleFonts.outfit(
              color: const Color(0xff76eb07),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            if (state.messages.isEmpty) {
              return Center(
                child: Text(
                  "No messages yet",
                  style: GoogleFonts.outfit(color: Colors.white24),
                ),
              );
            }
            return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[state.messages.length - 1 - index];
                return _buildMessageBubble(
                  msg.text, 
                  "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}", 
                  isMe: msg.isMe,
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator(color: Color(0xff76eb07)));
        },
      ),
    );
  }

  Widget _buildMessageBubble(String text, String time, {required bool isMe}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xff76eb07) : const Color(0xff1a1a1a),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(isMe ? 22 : 5),
                bottomRight: Radius.circular(isMe ? 5 : 22),
              ),
              boxShadow: isMe ? [
                BoxShadow(
                  color: const Color(0xff76eb07).withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ] : null,
            ),
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 15,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 20, MediaQuery.of(context).padding.bottom + 15),
      decoration: const BoxDecoration(
        color: Color(0xff121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white54, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: _messageController,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_messageController.text.trim().isNotEmpty) {
                context.read<ChatBloc>().add(ChatMessageSent(widget.userId, _messageController.text.trim()));
                _messageController.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xff76eb07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
