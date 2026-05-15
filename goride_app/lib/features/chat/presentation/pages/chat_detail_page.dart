
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_app/features/call/presentation/bloc/call_bloc.dart';
import 'package:goride_app/features/call/presentation/pages/call_page.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_bloc.dart';
import 'package:goride_app/features/explore/presentation/ride_tracking/bloc/ride_tracking_state.dart';
import '../bloc/chat_bloc.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_state.dart';
import 'package:goride_app/injection_container.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';

class ChatDetailPage extends StatefulWidget {
  final String userName;
  final String vehicle;
  final String receiverId;
  final bool isReadOnly;
  final String? profilePic;

  const ChatDetailPage({
    super.key,
    required this.userName,
    required this.vehicle,
    required this.receiverId,
    this.isReadOnly = false,
    this.profilePic,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print("CHAT_DETAIL: Initializing with receiverId: ${widget.receiverId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(ChatHistoryFetched(widget.receiverId));
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
        appBar: AppBar(
          backgroundColor: const Color(0xff121212),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: _handlePop,
          ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xff252525),
              radius: 18,
              backgroundImage: widget.profilePic != null && widget.profilePic!.isNotEmpty
                  ? NetworkImage(widget.profilePic!)
                  : null,
              child: widget.profilePic == null || widget.profilePic!.isEmpty
                  ? Text(
                      widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 14, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.vehicle,
                  style: GoogleFonts.poppins(
                    color: const Color(0xff76eb07),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              onPressed: () {
                context.read<CallBloc>().add(StartCallEvent(widget.receiverId, name: widget.userName));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<RideTrackingBloc>()),
                        BlocProvider.value(value: context.read<ExploreBloc>()),
                      ],
                      child: const CallPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.call_rounded,
                color: Color(0xff76eb07),
                size: 22,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(20),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[state.messages.length - 1 - index];
                        return _buildMessageBubble(
                          message.text,
                          message.isMe,
                          "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}",
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            if (widget.isReadOnly || _isPopping)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: Colors.white.withValues(alpha: 0.05),
                child: Center(
                  child: Text(
                    widget.isReadOnly 
                      ? "This is a past conversation (Read Only)"
                      : "",
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                  ),
                ),
              )
            else
              _buildMessageInput(),
          ],
        ),
      ),
      )
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xff76eb07) : const Color(0xff1a1a1a),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: isMe ? [
            BoxShadow(
              color: const Color(0xff76eb07).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: GoogleFonts.poppins(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.poppins(
                color: isMe ? Colors.black45 : Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, color: Colors.white54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _messageController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_messageController.text.isNotEmpty) {
                context.read<ChatBloc>().add(ChatMessageSent(
                  receiverId: widget.receiverId,
                  text: _messageController.text,
                ));
                _messageController.clear();
              }
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xff76eb07),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff76eb07).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
