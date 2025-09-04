// lib/screens/messages_list_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/models/message.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:medical_healthcare_app/screens/chat_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  Map<Doctor, Message> _latestMessagesByDoctor = {};

  bool _isSvg(String? url) {
    return url != null && url.toLowerCase().endsWith('.svg');
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _latestMessagesByDoctor = {};
      for (var message in DummyData.messages) {
        if (!_latestMessagesByDoctor.containsKey(message.recipient) ||
            message.timestamp.isAfter(
              _latestMessagesByDoctor[message.recipient]!.timestamp,
            )) {
          _latestMessagesByDoctor[message.recipient] = message;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Message> messageThreads = _latestMessagesByDoctor.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Messages',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: messageThreads.isEmpty
          ? Center(
              child: Text(
                'No messages yet. Start a conversation with a doctor!',
                style: AppStyles.bodyText1.copyWith(
                  color: AppColors.lightTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: messageThreads.length,
              itemBuilder: (context, index) {
                final Message latestMessage = messageThreads[index];
                final Doctor doctor = latestMessage.recipient;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: AppColors.cardColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.accentColor,
                      // FIX: Conditional rendering for SVG or NetworkImage, ensuring null safety
                      backgroundImage:
                          doctor.imageUrl != null && !_isSvg(doctor.imageUrl)
                          ? NetworkImage(doctor.imageUrl!)
                          : null,
                      child: doctor.imageUrl != null && _isSvg(doctor.imageUrl)
                          ? SvgPicture.network(
                              doctor.imageUrl!,
                              width: 56,
                              height: 56,
                              placeholderBuilder: (context) => Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            )
                          : doctor.imageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.white.withOpacity(0.8),
                            )
                          : null,
                    ),
                    title: Text(
                      'Dr. ${doctor.name}',
                      style: AppStyles.cardTitleStyle,
                    ),
                    subtitle: Text(
                      latestMessage.content,
                      style: AppStyles.bodyText2.copyWith(
                        color: AppColors.lightTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormat(
                        'MMM d, hh:mm a',
                      ).format(latestMessage.timestamp),
                      style: AppStyles.bodyText2.copyWith(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(doctor: doctor),
                        ),
                      ).then((_) {
                        _loadMessages();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
