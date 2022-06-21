import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/user_info.dart';
import '../providers/info_provider.dart';
import '../resources/permission.dart';
import '../utils/call_utilites.dart';

class HeadingChat extends StatelessWidget {
  final UserInfos chatterUser;
  final UserInfos userdata;
  const HeadingChat(
      {Key? key, required this.chatterUser, required this.userdata})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final result = Provider.of<InfoProviders>(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        chatterUser.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.pink,
            size: 28,
          )),
      actions: [
        // const Spacer(),
        InkWell(
          onTap: () async {
            result.checkAudioVideo(false);
            await Permissionss.cameraAndMicrophonePermissionsGranted()
                ? CallUtils.dial(
                    currUserId: userdata.userId,
                    currUserName: userdata.name,
                    currUserAvatar: userdata.imageUrls[0],
                    receiverId: chatterUser.userId,
                    receiverAvatar: chatterUser.imageUrls[0],
                    receiverName: chatterUser.name,
                    context: context)
                : {};
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(
              Icons.phone,
              color: Colors.pink,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 15),
        InkWell(
          onTap: () async {
            result.checkAudioVideo(true);
            await Permissionss.cameraAndMicrophonePermissionsGranted()
                ? CallUtils.dial(
                    currUserId: userdata.userId,
                    currUserName: userdata.name,
                    currUserAvatar: userdata.imageUrls[0],
                    receiverId: chatterUser.userId,
                    receiverAvatar: chatterUser.imageUrls[0],
                    receiverName: chatterUser.name,
                    context: context)
                : {};
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.pink,
              size: 28,
            ),
          ),
        ),
        SizedBox(width: 15),
      ],
    );
    // SizedBox(
    //   height: 70,
    //   child: Row(children: [
    //     const SizedBox(width: 8),
    //     IconButton(
    //         onPressed: () {
    //           Navigator.of(context).pop();
    //         },
    //         icon: const Icon(
    //           Icons.arrow_back,
    //           color: Colors.pink,
    //           size: 28,
    //         )),
    //     Text(
    //       chatterUser.name,
    //       style: const TextStyle(
    //         color: Colors.white,
    //         fontWeight: FontWeight.bold,
    //         fontSize: 24,
    //       ),
    //     ),
    //     const Spacer(),
    //     InkWell(
    //       onTap: () async {
    //         result.checkAudioVideo(false);
    //         await Permissionss.cameraAndMicrophonePermissionsGranted()
    //             ? CallUtils.dial(
    //                 currUserId: userdata.userId,
    //                 currUserName: userdata.name,
    //                 currUserAvatar: userdata.imageUrls[0],
    //                 receiverId: chatterUser.userId,
    //                 receiverAvatar: chatterUser.imageUrls[0],
    //                 receiverName: chatterUser.name,
    //                 context: context)
    //             : {};
    //       },
    //       child: Container(
    //         padding: const EdgeInsets.all(5),
    //         decoration: BoxDecoration(
    //             color: Colors.pink.withOpacity(0.2),
    //             borderRadius: BorderRadius.circular(10)),
    //         child: const Icon(
    //           Icons.phone,
    //           color: Colors.pink,
    //           size: 28,
    //         ),
    //       ),
    //     ),
    //     const SizedBox(width: 15),
    //     InkWell(
    //       onTap: () async {
    //         result.checkAudioVideo(true);
    //         await Permissionss.cameraAndMicrophonePermissionsGranted()
    //             ? CallUtils.dial(
    //                 currUserId: userdata.userId,
    //                 currUserName: userdata.name,
    //                 currUserAvatar: userdata.imageUrls[0],
    //                 receiverId: chatterUser.userId,
    //                 receiverAvatar: chatterUser.imageUrls[0],
    //                 receiverName: chatterUser.name,
    //                 context: context)
    //             : {};
    //       },
    //       child: Container(
    //         padding: const EdgeInsets.all(5),
    //         decoration: BoxDecoration(
    //             color: Colors.pink.withOpacity(0.2),
    //             borderRadius: BorderRadius.circular(10)),
    //         child: const Icon(
    //           Icons.videocam_rounded,
    //           color: Colors.pink,
    //           size: 28,
    //         ),
    //       ),
    //     ),
    //     const SizedBox(width: 22),
    //   ]),
    // );
  }
}
