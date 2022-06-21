import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  snackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'Receive an email to reset your password',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              // controller: _mySearched,
              cursorHeight: 22,
              // autofocus: true,
              cursorColor: Colors.pink,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.only(left: 25),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.pink, width: 2),
                    borderRadius: BorderRadius.circular(30)),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: 'Email',
                hintStyle: const TextStyle(
                    color: Colors.white24, fontSize: 15, wordSpacing: 2),
                fillColor: Colors.white24,
                filled: true,
                suffixIcon:
                    const Icon(Icons.email_outlined, color: Colors.grey),
              ),
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Please Enter your Email id';
                } else if (!val.contains('@') &&
                    !val.contains('.') &&
                    val.length < 10) {
                  return 'Please Enter a Valid Email id';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              // onPressed: () {},
              onPressed: resetPassword,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mail, size: 32, color: Colors.white70),
                  SizedBox(width: 10),
                  Text(
                    'Resent Email',
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  primary: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  )),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      snackBar('Password reset email send');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      // debugPrint(e.toString());
      Navigator.of(context).pop();
    }
  }
}
