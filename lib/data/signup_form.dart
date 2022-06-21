import 'package:bae_dating_app/data/verify_email.dart';
import 'package:bae_dating_app/screens/location_access.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/login.dart';
import '../auth/signup.dart';
import '../screens/forgot_password.dart';
import '../screens/home_page_screen.dart';
import '../screens/person_info.dart';
import '../screens/que_screen.dart';
import '../shared_preferences/user_values.dart';

class SignUpForm extends StatefulWidget {
  final bool isLogin;
  // final void Function(String email, String password, String username,
  //     bool isLogin, BuildContext context) submitFn;
  const SignUpForm({
    Key? key,
    required this.isLogin,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _form = GlobalKey<FormState>();
  String _emailAddress = '';
  String _userName = '';
  String _password = '';
  bool isVisible = false;
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserCredential? authResult;
  var _isLoading = false;
  loginForm(
      String email, String password, bool isLogin, BuildContext ctx) async {
    try {
      setState(() {
        _isLoading = true;
      });
      // if (widget.isLogin) {
      //print("EMAIL IN LOGIN SUBMIT FORM: $email");

      print('1');
      authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      // fetch user
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        //print('0');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (ctx) => const VerifyEmailPage()));
      } else {
        //print('2');
        if (authResult!.user != null) {
          final userData = await FirebaseFirestore.instance
              .collection('profile')
              .doc(authResult!.user!.uid)
              .get();
          // print(userData.data().toString());
          final isProfileComplete =
              userData.data()!['isProfileComplete'] ?? false;
          final isQNAcomplete = userData.data()!['isQNAcomplete'] ?? false;
          final isLocAccesGiven = userData.data()!['isLocAccesGiven'] ?? false;
          // print('$isProfileComplete || $isQNAcomplete');
          await setVisitingFlag(
            isLoginDone: true,
            isProfileDone: isProfileComplete,
            isQueAnsDone: isQNAcomplete,
            isPermiLocGiven: isLocAccesGiven,
          );
          if (isProfileComplete) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const HomePageScreen()));
          } else if(isLocAccesGiven) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (ctx) => const PersonInfo(
                      isEdit: false,
                    )));
          }
           else if (isQNAcomplete) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (ctx) => const LocationAccess()));
            // Navigator.of(context).pushReplacement(MaterialPageRoute(
            //     builder: (ctx) => const PersonInfo(
            //           isEdit: false,
            //         )));
          }
           else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const QueScreen()));
          }
        }
        // }
      }
    } on PlatformException catch (err) {
      var message = 'ERROR!!! Please Check Your Credentials';
      if (err.message != null) {
        message = err.message.toString();
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      // print("ERROR IS: ${err.toString()}");
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      //debugPrint(err.toString());
    }
  }

  void _signUpForm(String email, String password, String username, bool isLogin,
      BuildContext ctx) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (!isLogin) {
        authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        //SAVING SOMETHING TO FIRESTORE DATA
        await FirebaseFirestore.instance
            .collection('profile')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'username': username,
          'email': email,
        });
        if (authResult.user != null) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const VerifyEmailPage()));
        }
        setState(() {
          _isLoading = false;
        });
      }

      // email = '';
      // password = '';
      // username = '';
    } on PlatformException catch (err) {
      var message = 'ERROR!!! Please Check Your Credentials';
      if (err.message != null) {
        message = err.message.toString();
      }
      //debugPrint('$Error' + message);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: const Text('Email already exists. Log-In yourself!'),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
      //debugPrint(err.toString());
    }
  }

  // _trySubmit(BuildContext context) {
  //   var isValid = _form.currentState!.validate();
  //   if (isValid) {
  //     _form.currentState!.save();
  //     widget.submitFn(
  //       _emailAddress.trim(),
  //       _password.trim(),
  //       _userName.trim(),
  //       widget.isLogin,
  //       context,
  //     );
  //     _emailAddress = '';
  //     _password = '';
  //     _userName = '';
  //   }
  // }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("EMAIL CONTROLLER IN SIGNUP FORM: ${emailController.text}");
    return Form(
      key: _form,
      child: Column(
        children: [
          (!widget.isLogin)
              ? Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: TextFormField(
                    controller: userNameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    // autofocus: true,
                    maxLength: 25,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white24,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.pink,
                            width: 2.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.pink,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        // fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.pink,
                            width: 2.0,
                          ),
                        ),
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Colors.white),
                        floatingLabelStyle: const TextStyle(color: Colors.pink),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          // gapPadding: 8,
                          borderRadius: BorderRadius.circular(20),
                        )),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 2) {
                        return 'Enter Username with Min Length 3';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _userName = val.toString();
                    },
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: TextFormField(
              controller: emailController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              keyboardType: TextInputType.emailAddress,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelStyle: const TextStyle(color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
              textInputAction: TextInputAction.done,
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Please Enter Email Address';
                } else if (!(val.contains('@') && val.contains('.com'))) {
                  return 'Enter a Valid Email Address';
                }
                return null;
              },
              onSaved: (val) {
                // _emailAddress = val.toString();
                _emailAddress = emailController.text;
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: TextFormField(
              controller: passwordController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              obscureText: isVisible ? false : true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                    child: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility_sharp,
                      color: Colors.white,
                    ),
                  ),
                  floatingLabelStyle: const TextStyle(color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter your Password';
                } else if (value.length < 7) {
                  return 'For Strong Password Length Must be Min 8 Characters';
                }
                return null;
              },
              onSaved: (val) {
                // _password = val.toString();
                _password = passwordController.text;
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            // width: deviceSize.width * 0.7,
            width: 250,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: ElevatedButton(
              onPressed: () {
                // _trySubmit(context);
                widget.isLogin
                    ? loginForm(emailController.text, passwordController.text,
                        true, context)
                    : _signUpForm(emailController.text, passwordController.text,
                        userNameController.text, false, context);
              },
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      widget.isLogin ? 'Log In' : 'Sign Up',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
              style: ElevatedButton.styleFrom(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.all(18),
                  primary: Colors.pink),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isLogin
                    ? 'Don\'t have an Account?'
                    : 'Already have an Account?',
                style: const TextStyle(color: Colors.white),
              ),
              TextButton(
                  onPressed: () {
                    widget.isLogin
                        ? Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => const SignUp()))
                        : Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => const Login()));
                  },
                  child: Text(
                    widget.isLogin ? 'Sign Up' : 'Log In',
                    style: const TextStyle(
                        color: Colors.pink, fontWeight: FontWeight.bold),
                  ))
            ],
          ),
          const SizedBox(height: 20),
          widget.isLogin
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Forgot your password?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const ForgotPassword()));
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                              color: Colors.pink, fontWeight: FontWeight.bold),
                        ))
                  ],
                )
              : const SizedBox(),
          //PHONE NUMBER LOGIN COMMENTED

          // const Divider(
          //   color: Colors.white,
          //   indent: 30,
          //   endIndent: 30,
          //   thickness: 0.5,
          // ),
          // const SizedBox(height: ),
          // const Text(
          //   'Or Login with',
          //   style: TextStyle(color: Colors.white, fontSize: 12),
          // ),
          // const SizedBox(height: 8),
          // SizedBox(
          //   // width: deviceSize.width * 0.5,
          //   width: 180,
          //   height: 50,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       Navigator.pushReplacement(context,
          //           MaterialPageRoute(builder: (ctx) => const PhoneLogin()));
          //     },
          //     child: const Text('Phone Number',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 17,
          //         )),
          //     style: ElevatedButton.styleFrom(
          //       elevation: 20,
          //       primary: Colors.pinkAccent,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(20)),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
