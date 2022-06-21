import 'package:bae_dating_app/screens/person_info.dart';
import 'package:bae_dating_app/shared_preferences/user_values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LocationAccess extends StatefulWidget {
  const LocationAccess({Key? key}) : super(key: key);

  @override
  State<LocationAccess> createState() => _LocationAccessState();
}

class _LocationAccessState extends State<LocationAccess> {
  bool isLoading = false;
  snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.pink,
          title: const Text(
            '      Location Access',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          )),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        isLoading
            ? Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(left: 40, right: 40),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 206, 94, 130),
                    borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color.fromARGB(255, 206, 94, 130),
                title: const Text(
                  'Location Access',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'BAE app needs your location for finding your other half near you',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  SizedBox(
                    // height: 32,
                    width: 90,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await setVisitingFlag(isPermiLocGiven: true);
                        await FirebaseFirestore.instance
                            .collection('profile')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({"isLocAccesGiven": true});
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (ctx) => const PersonInfo(isEdit: false)));
                      },
                      child: const Text(
                        'I accept',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(244, 223, 31, 101),
                          elevation: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      snackBar('Sorry you cannot proceed further', context);
                    },
                    child: const Text(
                      'I deny',
                      style: TextStyle(fontSize: 17),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.white.withOpacity(0.8),
                    ),
                  )
                ],
              )
      ]),
    );
  }
}
