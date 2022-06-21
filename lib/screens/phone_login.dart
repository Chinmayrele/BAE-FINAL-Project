import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../auth/login.dart';
import './otp_screen.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({Key? key}) : super(key: key);

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final myNumberController = TextEditingController();
  String myPhoneNumber = '';
  var isLoading = false;
  String verifyId = '';
  FirebaseAuth auth = FirebaseAuth.instance;

  snackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : ListView(children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 15),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 28,
                      )),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 15),
                child: Image.asset(
                  'assets/images/bae_flogo.png',
                  // fit: BoxFit.cover,
                ),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    'What\'s your Number?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.pink[400],
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: const Text(
                    'Please enter your phone number and we will send you a SMS verification code',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IntlPhoneField(
                  initialCountryCode: 'IN',
                  controller: myNumberController,
                  dropdownTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  cursorColor: Colors.pink,
                  keyboardType: TextInputType.number,
                  keyboardAppearance: Brightness.dark,
                  decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.pink,
                          width: 2,
                        )),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.pink,
                          width: 2,
                        )),
                    fillColor: Colors.white24,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.pink,
                          width: 2,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Colors.pink,
                          width: 2,
                        )),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    floatingLabelStyle: const TextStyle(
                        color: Colors.pink, fontWeight: FontWeight.normal),
                    label: const Text('Phone Number'),
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 18),
                    prefixIcon: const Icon(Icons.phone_forwarded_outlined,
                        color: Colors.white),
                    // prefixText: '  +91 ',
                    // prefixStyle: const TextStyle(
                    //     fontSize: 20,
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold),
                  ),
                  onChanged: (phone) {
                    //debugPrint(phone.completeNumber);
                    myPhoneNumber = phone.completeNumber;
                  },
                  onCountryChanged: (country) {
                    //debugPrint('Country changed to: ' + country.name);
                  },
                ),
                // TextField(
                //   style: const TextStyle(
                //       fontSize: 20,
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold),
                //   controller: myNumberController,
                //   maxLength: 10,
                //   maxLengthEnforcement: MaxLengthEnforcement.enforced,
                //   cursorColor: Colors.pink,
                //   keyboardType: TextInputType.number,
                //   keyboardAppearance: Brightness.dark,
                //   decoration: InputDecoration(
                //     fillColor: Colors.white24,
                //     filled: true,
                //     focusedBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(40),
                //         borderSide: const BorderSide(
                //           color: Colors.pink,
                //           width: 2,
                //         )),
                //     enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(40),
                //         borderSide: const BorderSide(
                //           color: Colors.pink,
                //           width: 2,
                //         )),
                //     contentPadding: const EdgeInsets.symmetric(
                //         vertical: 15, horizontal: 15),
                //     floatingLabelAlignment: FloatingLabelAlignment.start,
                //     floatingLabelStyle: const TextStyle(
                //         color: Colors.pink, fontWeight: FontWeight.normal),
                //     label: const Text('Phone Number'),
                //     labelStyle: const TextStyle(
                //         fontWeight: FontWeight.normal,
                //         color: Colors.white,
                //         fontSize: 18),
                //     prefixIcon: const Icon(Icons.phone_forwarded_outlined,
                //         color: Colors.white),
                //     prefixText: '  +91 ',
                //     prefixStyle: const TextStyle(
                //         fontSize: 20,
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold),
                //   ),
                // ),
              ),
              // SizedBox(height: 40),
              SizedBox(height: MediaQuery.of(context).size.height * 0.21),
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: ElevatedButton(
                  child: const Text(
                    'Request OTP',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    await auth.verifyPhoneNumber(
                      phoneNumber: myPhoneNumber,
                      verificationCompleted: (v) {
                        //debugPrint("TOKEN: ${v.token}");
                        //debugPrint("Verfication ID: ${v.verificationId}");
                        //debugPrint("Provider ID: ${v.providerId}");
                        //debugPrint("SIGN in Meyhod: ${v.signInMethod}");
                        setState(() async {
                          isLoading = false;
                        });
                      },
                      verificationFailed: (verificationFailed) async {
                        setState(() {
                          isLoading = false;
                        });
                        snackBar(verificationFailed.toString());
                      },
                      codeSent: (vId, token) async {
                        setState(() {
                          isLoading = false;
                          verifyId = vId;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => OtpRequest(
                                    auth: auth, verificationId: verifyId)),
                          );
                        });
                      },
                      codeAutoRetrievalTimeout: (v) {
                        // snackBar(v.toString());
                        setState(() {
                          isLoading = false;
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    primary: Colors.pink,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login in with Email?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => const Login()));
                        // : Navigator.of(context).pushReplacement(
                        //     MaterialPageRoute(
                        //         builder: (ctx) => const PhoneLogin()));
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                            color: Colors.pink, fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              const SizedBox(height: 30)
            ]),
    );
  }
}
