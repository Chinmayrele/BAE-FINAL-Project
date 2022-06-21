import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CallScreens/pickup/circle_painter.dart';
import '../CallScreens/pickup/curve_wave.dart';
import '../data/constants.dart';
import '../models/call.dart';
import '../models/log.dart';
import '../resources/call_methods.dart';
import '../settings.dart';

class AudioScreen extends StatefulWidget {
  final Call call;

  const AudioScreen({
    Key? key,
    required this.call,
  }) : super(key: key);

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen>
    with SingleTickerProviderStateMixin {
  final CallMethods callMethods = CallMethods();

  late SharedPreferences preferences;
  late StreamSubscription callStreamSubscription;
  late AnimationController _controller;
  Color rippleColor = Colors.red;

  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool hasUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this);
    addPostFrameCallback();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    // INITIALIZED ENGINE TODAY
    // _engine = await RtcEngine.createWithContext(RtcEngineContext(APP_ID));
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    // await _engine.setParameters(
    //     '''{"che.video.lowBitRateStreamParameter":{"width":320,"height":180,"frameRate":15,"bitRate":140}}''');
    await _engine.joinChannel(null, widget.call.channelId.toString(), null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableAudio();
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // await _engine
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      // firstRemoteVideoFrame: (uid, width, height, elapsed) {
      //   setState(() {
      //     final info = 'firstRemoteVideo: $uid ${width}x $height';
      //     _infoStrings.add(info);
      //   });
      // }
    ));
  }

  /// Create agora sdk instance and initialize

  addPostFrameCallback() async {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      callStreamSubscription = callMethods
          .callStream(uid: widget.call.callerId.toString())
          .listen((DocumentSnapshot ds) {
        if (ds.data() == null) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              callMethods.endCall(
                call: widget.call,
              );

              if (!hasUserJoined) {
                Log log = Log(
                    callerName: widget.call.callerName,
                    callerPic: widget.call.callerPic,
                    receiverName: widget.call.receiverName,
                    receiverPic: widget.call.receiverPic,
                    timestamp: DateTime.now().toString(),
                    callStatus: CALL_STATUS_MISSED,
                    logId: null);

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
            },
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          // RawMaterialButton(
          //   onPressed: _onSwitchCamera,
          //   child: Icon(
          //     Icons.switch_camera,
          //     color: Colors.blueAccent,
          //     size: 20.0,
          //   ),
          //   shape: CircleBorder(),
          //   elevation: 2.0,
          //   fillColor: Colors.white,
          //   padding: const EdgeInsets.all(12.0),
          // )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[rippleColor, Colors.black12],
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
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                  ),
                  width: 180.0,
                  height: 180.0,
                  padding: const EdgeInsets.all(70.0),
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
                imageUrl: widget.call.receiverPic.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 100),
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
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    widget.call.receiverName.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
