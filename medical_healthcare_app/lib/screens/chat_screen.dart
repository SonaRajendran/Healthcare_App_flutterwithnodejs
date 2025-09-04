// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/models/message.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreen extends StatefulWidget {
  final Doctor doctor;

  const ChatScreen({super.key, required this.doctor});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _currentChatMessages = [];

  bool _isSvg(String? url) {
    return url != null && url.toLowerCase().endsWith('.svg');
  }

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadChatMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatMessages() {
    setState(() {
      _currentChatMessages =
          DummyData.messages
              .where((msg) => msg.recipient.id == widget.doctor.id)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final String userMessageContent = _messageController.text.trim();

    final newMessage = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      recipient: widget.doctor,
      sender: MessageSender.user,
      content: userMessageContent,
      timestamp: DateTime.now(),
    );

    DummyData.addMessage(newMessage);
    _messageController.clear();
    _loadChatMessages();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      _simulateDoctorReply(userMessageContent);
    });
  }

  void _simulateDoctorReply(String userMessage) {
    String replyContent;
    if (userMessage.toLowerCase().contains('hello') ||
        userMessage.toLowerCase().contains('hi')) {
      replyContent = 'Hello there! How can I assist you today?';
    } else if (userMessage.toLowerCase().contains('appointment')) {
      replyContent =
          'Please check the "Appointments" tab for your upcoming bookings or to schedule a new one.';
    } else if (userMessage.toLowerCase().contains('test results')) {
      replyContent =
          'Your test results will be available in the patient portal. I\'ll notify you once they are updated.';
    } else if (userMessage.toLowerCase().contains('thank you') ||
        userMessage.toLowerCase().contains('thanks')) {
      replyContent = 'You\'re most welcome! Is there anything else?';
    } else {
      replyContent =
          'I\'ve received your message. I\'ll get back to you shortly.';
    }

    final doctorReply = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      recipient: widget.doctor,
      sender: MessageSender.doctor,
      content: replyContent,
      timestamp: DateTime.now(),
    );

    DummyData.addMessage(doctorReply);
    _loadChatMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? doctorImageUrl =
        widget.doctor.imageUrl; // FIX: Assign to local nullable variable

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            if (doctorImageUrl != null) // FIX: Check local nullable variable
              _isSvg(doctorImageUrl)
                  ? SvgPicture.network(
                      doctorImageUrl, // No '!' needed here as it's already type String
                      width: 36,
                      height: 36,
                      placeholderBuilder: (context) => const CircleAvatar(
                        // FIX: Added const
                        radius: 18,
                        backgroundColor: AppColors.accentColor,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.accentColor,
                      backgroundImage: NetworkImage(
                        doctorImageUrl,
                      ), // No '!' needed here
                      onBackgroundImageError: (exception, stackTrace) => {},
                    )
            else
              const CircleAvatar(
                // FIX: Added const
                radius: 18,
                backgroundColor: AppColors.accentColor,
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
            const SizedBox(width: 10),
            Text(
              'Dr. ${widget.doctor.name}',
              style: AppStyles.headline2.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _currentChatMessages.length,
              itemBuilder: (context, index) {
                final message = _currentChatMessages[index];
                final bool isMe = message.sender == MessageSender.user;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primaryColor
                          : AppColors.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isMe
                            ? const Radius.circular(15)
                            : const Radius.circular(5),
                        bottomRight: isMe
                            ? const Radius.circular(5)
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: AppStyles.bodyText1.copyWith(
                            color: isMe ? Colors.white : AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(message.timestamp),
                          style: AppStyles.bodyText2.copyWith(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white70
                                : AppColors.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: AppStyles.bodyText2.copyWith(
                        color: AppColors.lightTextColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    style: AppStyles.bodyText1,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: AppColors.primaryColor,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
