import 'package:bae_dating_app/screens/que_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../shared_preferences/user_values.dart';
import './home_page_screen.dart';

class OtpRequest extends StatefulWidget {
  final FirebaseAuth auth;
  final String verificationId;

  const OtpRequest({
    Key? key,
    required this.auth,
    required this.verificationId,
  }) : super(key: key);
  @override
  _OtpRequestState createState() => _OtpRequestState();
}

class _OtpRequestState extends State<OtpRequest> {
  TextEditingController otpEditingController = TextEditingController();
  bool hasError = false;
  String currentText = "";
  bool isLoading = false;
  bool isUserFirstTime = true;

  // snackBar(String message) {
  //   return ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  void signInWithPhoneCredential(PhoneAuthCredential phoneCredential) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (widget.auth.currentUser != null) {}
      final authCredential =
          await widget.auth.signInWithCredential(phoneCredential);
      setState(() {
        isLoading = false;
      });

      if (authCredential.user != null) {
        await setVisitingFlag(isLoginDone: true);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => const QueScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx) => const HomePageScreen(),
        ));
      }
    } on FirebaseException catch (e) {
      // snackBar(e.message.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              child: Image.asset(
                'assets/images/bae_flogo.png',
                // fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 50),
            const Center(
              child: Text(
                'Code has been sent to mobile no.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 30,
              ),
              child: PinCodeTextField(
                textStyle: const TextStyle(color: Colors.white),
                appContext: context,
                pastedTextStyle: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                ),
                length: 6,
                blinkWhenObscuring: true,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  borderWidth: 2.5,
                  inactiveColor: Colors.white24,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white24,
                ),
                animationDuration: const Duration(milliseconds: 300),
                controller: otpEditingController,
                keyboardType: TextInputType.number,
                onCompleted: (v) {
                  //debugPrint("Completed");
                },
                onChanged: (value) {
                  //debugPrint(value);
                  setState(() {
                    currentText = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                TextButton(
                    onPressed: () {
                      //debugPrint('OTP Resend!');
                    },
                    child: const Text(
                      "RESEND",
                      style: TextStyle(
                          color: Color(0xFF91D3B3),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ))
              ],
            ),
            const SizedBox(height: 14),
            Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      PhoneAuthCredential phoneCredential =
                          PhoneAuthProvider.credential(
                        verificationId: widget.verificationId,
                        smsCode: otpEditingController.text,
                      );
                      signInWithPhoneCredential(phoneCredential);
                    },
                    child: Center(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "VERIFY".toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.pink,
                        offset: Offset(-1, 2),
                        blurRadius: 5)
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    child: TextButton(
                  child: const Text("Clear"),
                  onPressed: () {
                    otpEditingController.clear();
                  },
                )),
                // Flexible(
                //     child: TextButton(
                //   child: const Text("Set Text"),
                //   onPressed: () {},
                // )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
