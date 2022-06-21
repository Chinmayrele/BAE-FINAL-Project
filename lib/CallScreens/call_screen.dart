import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/constants.dart';
import '../models/call.dart';
import '../models/log.dart';
import '../resources/call_methods.dart';
import '../settings.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  late SharedPreferences preferences;
  late StreamSubscription callStreamSubscription;

  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool hasUserJoined = false;
   late RtcEngine _engine;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addPostFrameCallback();
    initializeAgora();
  }
  // String baseUrl = "https://console.agora.io/en/project/WNEwlEA3Y";
  // late String token;

  // Future<void> getToken() async {
  //   final response = await http.get(
  //     Uri.parse(baseUrl + '/rtc/' + widget.call.channelId.toString() + '/publisher/uid/' + widget.call.callerId.toString()
  //       // To add expiry time uncomment the below given line with the time in seconds
  //       // + '?expiry=45'
  //     ),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       token = response.body;
  //       token = jsonDecode(token)['rtcToken'];
  //     });
  //   } else {
  //     print('Failed to fetch the token');
  //   }
  // }

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
    await _engine.enableWebSdkInteroperability(true);

    await _engine.setParameters(
        '''{"che.video.lowBitRateStreamParameter":{"width":320,"height":180,"frameRate":15,"bitRate":140}}''');
    await _engine.joinChannel(null, widget.call.channelId.toString(), null, 0);
  }
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // await _engine
  }
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }
  /// Create agora sdk instance and initialize

  addPostFrameCallback() async {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      callStreamSubscription = callMethods
          .callStream(uid: widget.call.callerId.toString())
          .listen((DocumentSnapshot ds) {
        if(ds.data()==null){
          Navigator.of(context).pop();
        }
      });
    });

  }

  /// Helper function to get list of native views
  List _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(
        RtcRemoteView.SurfaceView(uid: uid, channelId: widget.call.channelId.toString())));


    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      default:
    }
    return Container();
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
            shape: CircleBorder(),
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
                    callStatus: CALL_STATUS_MISSED, logId: null);

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
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
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
                          style: TextStyle(color: Colors.blueGrey),
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

  void _onSwitchCamera() {
    _engine.switchCamera();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}


