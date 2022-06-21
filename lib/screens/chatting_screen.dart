import 'package:flutter/material.dart';

import '../CallScreens/pickup/pickup_layout.dart';
import '../data/new_message.dart';
import '../models/user_info.dart';
import 'chating.dart';
import 'heading_chat.dart';

class ChattingScreen extends StatefulWidget {
  final UserInfos chaterUser;
  final UserInfos userdata;

  const ChattingScreen({
    Key? key,
    required this.chaterUser,
    required this.userdata,
  }) : super(key: key);

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return PickupLayout(
      scaffold: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              HeadingChat(
                  chatterUser: widget.chaterUser, userdata: widget.userdata),
              Chatting(chatterUser: widget.chaterUser),
              NewMessage(chatterUser: widget.chaterUser),
            ],
          ),
        ),
      ),
      uid: widget.userdata.userId,
    );
  }
}
