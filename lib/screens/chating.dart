import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/message_bubble.dart';
import '../models/user_info.dart';

class Chatting extends StatefulWidget {
  final UserInfos chatterUser;
  const Chatting({Key? key, required this.chatterUser}) : super(key: key);

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final logUserId = FirebaseAuth.instance.currentUser!.uid;
    final strCompare = logUserId.compareTo(widget.chatterUser.userId);
    final docId = strCompare == -1
        ? logUserId + widget.chatterUser.userId
        : widget.chatterUser.userId + logUserId;
    return Container(
      height: size.height * 0.74,
      padding: const EdgeInsets.all(10),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatRoom')
            .doc(docId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, streamSnapshots) {
          if (streamSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white,),
            );
          }
          final chatDocs = streamSnapshots.data!.docs;
          return ListView.builder(
            reverse: true,
            itemBuilder: (ctx, index) {
              return MessageBubble(
                text: chatDocs[index]['text'],
                isMe: chatDocs[index]['senderId'] ==
                    FirebaseAuth.instance.currentUser!.uid,
                // key: ValueKey(chatDocs[index].data().toString())
              );
            },
            itemCount: chatDocs.length,
          );
        },
      ),
    );
  }
}
