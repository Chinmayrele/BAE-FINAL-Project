import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/signup_form.dart';
import '../providers/info_provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isQueAnsFilled = false;
  late InfoProviders result;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                // width: double.infinity,
                child: Image.asset(
                  'assets/images/bae_flogo.png',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Log In',
                // '𝓛𝓸𝓰-𝓘𝓷',
                style: GoogleFonts.kdamThmor(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please login to continue using our app',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              const SignUpForm(
                isLogin: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
