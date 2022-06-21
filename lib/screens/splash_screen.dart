import 'dart:async';
import 'dart:convert';
import 'package:bae_dating_app/screens/location_access.dart';
import 'package:bae_dating_app/screens/person_info.dart';
import 'package:bae_dating_app/screens/que_screen.dart';
import 'package:bae_dating_app/screens/start_screen.dart';
import 'package:flutter/material.dart';

import '../shared_preferences/user_values.dart';
import 'home_page_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    //debugPrint("INIT State");
    timerFunction();

    super.initState();
  }

  timerFunction() async {
    Future.delayed(const Duration(seconds: 3), () async {
      final String isVisited = await getVisitingFlag();
      // debugPrint("Value String: $isVisited");
      if (isVisited.isNotEmpty) {
        Map<String, dynamic> mp = json.decode(isVisited);
        // debugPrint("Value : ${mp['isProfileDone']}");
        if (mp.containsKey('isProfileDone') && mp['isProfileDone']) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const HomePageScreen()));
        }
        // else if (mp.containsKey('isLocDone') && mp['isLocDone']) {
        //   Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       builder: (ctx) => PersonInfo(
        //             isEdit: false,
        //           )));
        // }
        else if(mp.containsKey('isLocAccesGiven') && mp['isLocAccesGiven']) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (ctx) => const PersonInfo(
                    isEdit: false,
                  )));
        }
        else if (mp.containsKey('isQueAnsDone') && mp['isQueAnsDone']) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (ctx) => const LocationAccess()));
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (ctx) => const PersonInfo(
          //           isEdit: false,
          //         )));
        } else if(mp.containsKey('isLoginDone') && mp['isLoginDone']){
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const QueScreen()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const StartScreen()));
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const StartScreen()));
      }

      // setState(() {
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (ctx) => const StartScreen()));
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: SizedBox(
        height: size.height * 0.4,
        // width: size.width * 0.2,
        child: Image.asset(
          'assets/images/bae_flogo.png',
        ),
      )),
    );
  }
}
