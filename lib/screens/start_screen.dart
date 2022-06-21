import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login.dart';
import '../auth/signup.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: deviceSize.height * 0.1),
            SizedBox(
              height: deviceSize.height * 0.18,
              width: double.infinity,
              child: Image.asset(
                'assets/images/bae_flogo.png',
              ),
            ),
            SizedBox(height: deviceSize.height * 0.08),
            Text('Welcome!',
                style: GoogleFonts.kdamThmor(
                    letterSpacing: 2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35)),
            SizedBox(height: deviceSize.height * 0.05),
            Container(
              margin: EdgeInsets.all(deviceSize.width * 0.06),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //PHONE NUMBER LOGIN COMMENTED
                  //FOR PHONE LOGIN TYPE PHONELOGIN()
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (ctx) => const SignUp()));
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.all(25),
                    primary: Colors.pink),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an Account?',
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (ctx) => const Login()));
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
