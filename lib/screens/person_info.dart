import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_tinder_clone_app/data/user_info_form.dart';

import '../data/user_info_form.dart';

class PersonInfo extends StatefulWidget {
  final bool isEdit;
  // final double latitude;
  // final double longitude;
  const PersonInfo({
    Key? key,
    required this.isEdit,
    // this.latitude = 0,
    // this.longitude = 0,
  }) : super(key: key);

  @override
  State<PersonInfo> createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
  double latitude = 0;
  double longitude = 0;
  bool isLocLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                widget.isEdit
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.pink,
                          size: 26,
                        ))
                    : const SizedBox(),
                const SizedBox(width: 22),
                const Text(
                  'Fill Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // UserInfoForm(
            //     latitude: widget.latitude, longitude: widget.longitude),
            UserInfoForm(isEdit: widget.isEdit),
          ],
        ),
      ),
    );
  }
}
