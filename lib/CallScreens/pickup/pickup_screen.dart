// import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';

import '../../data/constants.dart';
import '../../models/call.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/log.dart';
import '../../providers/info_provider.dart';
import '../../resources/call_methods.dart';
import '../../resources/permission.dart';
import '../../screens/audio_screen.dart';
import '../call_screen.dart';
import 'circle_painter.dart';
import 'curve_wave.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen>
    with TickerProviderStateMixin {
  final CallMethods callMethods = CallMethods();
  late AnimationController _controller;
  Color rippleColor = Colors.red;
  bool isCallMissed = true;

  @override
  void initState() {
    //print("============INIT==================");
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    //print("=======DISPOSE=========");
    super.dispose();
  }

  // add call logs to db
  addCallLogsToDb({required String callStatus}) {
    Log log = Log(
        callerName: widget.call.callerName,
        callerPic: widget.call.callerPic,
        receiverName: widget.call.receiverName,
        receiverPic: widget.call.receiverPic,
        timestamp: DateTime.now().toString(),
        callStatus: callStatus, logId: null);

    FirebaseFirestore.instance
        .collection("profile")
        .doc(widget.call.receiverId)
        .collection("callLogs")
        .doc(log.timestamp)
        .set({
      "callerName": log.callerName,
      "callerPic": log.callerPic,
      "receiverName": log.receiverName,
      "receiverPic": log.receiverPic,
      "timestamp": log.timestamp,
      "callStatus": log.callStatus
    });
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                rippleColor,
                Colors.black12
              ],
            ),
          ),
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const CurveWave(),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                  ),
                  width: 180.0,
                  height: 180.0,
                  padding: EdgeInsets.all(70.0),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                errorWidget: (context, url, error) => Material(
                  child: Image.asset(
                    "images/img_not_available.jpeg",
                    width: 180.0,
                    height: 180.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: widget.call.callerPic.toString(),
                width: 180.0,
                height: 180.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pickCall(BuildContext context) async {
    isCallMissed = false;
    addCallLogsToDb(callStatus: CALL_STATUS_RECEIVED);
    FlutterRingtonePlayer.stop();
    await Permissionss.cameraAndMicrophonePermissionsGranted();
    final result = Provider.of<InfoProviders>(context, listen: false);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => result.call_type
              ? CallScreen(
            call: widget.call,
          )
              : AudioScreen(call: widget.call),
        ));
  }

  double shake(double animation) =>
      2 * (0.5 - (0.5 - Curves.bounceOut.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              painter: CirclePainter(
                _controller,
                color: rippleColor,
              ),
              child: SizedBox(
                width: 320.0,
                height: 180.0,
                child: _button(),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Incoming...",
              style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300),
            ),
            // SizedBox(
            //   height: 50,
            // ),
            // CachedImage(
            //   widget.call.callerPic.toString(),
            //   isRound: true,
            //   radius: 180,
            // ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.call.callerName.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 75,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.redAccent),
                  // color: Colors.redAccent,
                  child: IconButton(
                    iconSize: 30.0,
                    icon: Icon(Icons.call_end),
                    color: Colors.white,
                    onPressed: () async {
                      isCallMissed = false;
                      // addCallLogsToDb(callStatus: CALL_STATUS_RECEIVED);
                      await callMethods.endCall(call: widget.call);
                    },
                  ),
                ),
                SizedBox(
                  width: 25,
                ),
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.green),
                  child: IconButton(
                      iconSize: 30.0,
                      icon: Icon(Icons.call),
                      color: Colors.white,
                      onPressed: () => pickCall(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
