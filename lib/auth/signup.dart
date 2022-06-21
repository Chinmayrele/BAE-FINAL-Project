import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/signup_form.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  static const routeName = 'signup';

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: deviceSize.height * 0.22,
              // width: double.infinity,
              child: Image.asset(
                'assets/images/bae_flogo.png',
              ),
            ),
            const SizedBox(height: 10),
            Text('Sign Up',
                style: GoogleFonts.kdamThmor(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30)),
            const SizedBox(height: 10),
            const Text(
              'Please sign up to start using our app',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: deviceSize.height * 0.03,
            ),
            const SignUpForm(
              isLogin: false,
            ),
          ],
        ),
      )),
    );
  }
}
