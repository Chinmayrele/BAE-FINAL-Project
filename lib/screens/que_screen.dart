import 'package:bae_dating_app/screens/location_access.dart';
import 'package:bae_dating_app/screens/person_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global/que_ans_list.dart';
import '../global/title_text.dart';
import '../models/que_ans_info.dart';
import '../providers/info_provider.dart';
import '../shared_preferences/user_values.dart';

class QueScreen extends StatefulWidget {
  const QueScreen({Key? key}) : super(key: key);

  @override
  State<QueScreen> createState() => _QueScreenState();
}

class _QueScreenState extends State<QueScreen> {
  String? _lookStatus;
  String? _vacaStatus;
  String? _nightStatus;
  String? _smokeStatus;
  String? _drinkStatus;
  String? _exerciseStatus;
  String? _htStatus;
  bool isLoading = false;

  snackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // titleText(String text, bool isRequired) {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 25, bottom: 8, top: 15),
  //     child: RichText(
  //         text: TextSpan(
  //             text: text,
  //             style: const TextStyle(
  //                 color: Colors.white, fontWeight: FontWeight.bold),
  //             children: [
  //           if (isRequired)
  //             const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
  //         ])),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final queAnsFill = Provider.of<InfoProviders>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.33),
                const Text(
                  'Profile Info',
                  style: TextStyle(
                      color: Colors.pink,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(
              color: Colors.white24,
              endIndent: 15,
              indent: 15,
              thickness: 1.5,
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.only(left: 12, right: 10),
              width: MediaQuery.of(context).size.width * 0.9,
              child: const Text(
                'Please answer the following questions so we could understand you better',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.white24,
              endIndent: 15,
              indent: 15,
              thickness: 1.5,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.86,
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText('What are you looking for here?', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Relationship/friends/etc',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: lookingStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _lookStatus,
                          onChanged: (val) {
                            setState(() {
                              _lookStatus = val as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                    //2nd QUE
                    titleText(
                        'What would decribe your ideal location place?', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'Vacation Mode',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: vacationStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _vacaStatus,
                          onChanged: (value) {
                            setState(() {
                              _vacaStatus = value as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                    //3rd QUE
                    titleText('When it comes to nightlife...', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'Night moods',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: nightingStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _nightStatus,
                          onChanged: (value) {
                            setState(() {
                              _nightStatus = value as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                    //4th QUE
                    titleText('Your Opinion on Smoking?', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'What you say',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: smokingStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _smokeStatus,
                          onChanged: (value) {
                            setState(() {
                              _smokeStatus = value as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                    //5th QUE
                    titleText('Your Opinion on Drinking?', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'What you say',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: drinkingStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _drinkStatus,
                          onChanged: (value) {
                            setState(() {
                              _drinkStatus = value as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                    //6th QUE
                    titleText('What are your exercise habits?', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'Do you exercise',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: exercisingStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _exerciseStatus,
                          onChanged: (value) {
                            setState(() {
                              _exerciseStatus = value as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                    //7th QUE
                    titleText('What is your Height?', true),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: Row(
                            children: const [
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'Height',
                                  style: TextStyle(
                                    fontSize: 15,
                                    wordSpacing: 2,
                                    color: Colors.white24,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: heightStatus
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _htStatus,
                          onChanged: (value) {
                            setState(() {
                              _htStatus = value as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 150,
                          buttonPadding:
                              const EdgeInsets.only(left: 24, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.pink, width: 2),
                            color: Colors.white24,
                          ),
                          buttonElevation: 2,
                          itemHeight: 40,
                          itemPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          dropdownMaxHeight: 200,
                          dropdownWidth:
                              MediaQuery.of(context).size.width * 0.92,
                          dropdownPadding: const EdgeInsets.only(left: 24),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink,
                          ),
                          dropdownElevation: 8,
                          scrollbarRadius: const Radius.circular(30),
                          scrollbarThickness: 6,
                          scrollbarAlwaysShow: true,
                          offset: const Offset(0, 0),
                        ),
                      ),
                    ),
                  ]),
            ),
            Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: ElevatedButton(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                onPressed: () async {
                  if (_lookStatus!.isEmpty &&
                      _vacaStatus!.isEmpty &&
                      _nightStatus!.isEmpty &&
                      _smokeStatus!.isEmpty &&
                      _drinkStatus!.isEmpty &&
                      _exerciseStatus!.isEmpty &&
                      _htStatus!.isEmpty) {
                    return snackBar('Please Fill all the info here!');
                  }
                  setState(() {
                    isLoading = true;
                  });
                  //FIREBASE LOGIC
                  await queAnsFill.addQueAnsInfo(QueAnsInfo(
                    relationStatus: _lookStatus.toString(),
                    vacationStatus: _vacaStatus.toString(),
                    nightStatus: _nightStatus.toString(),
                    smokeStatus: _smokeStatus.toString(),
                    drinkStatus: _drinkStatus.toString(),
                    exerciseStatus: _exerciseStatus.toString(),
                    heightStatus: _htStatus.toString(),
                    // isQueAnsFilled: true,
                  ));
                  await FirebaseFirestore.instance
                      .collection('profile')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                        "isQNAcomplete": true,
                      });
                  await setVisitingFlag(isQueAnsDone: true);
                  setState(() {
                    isLoading = false;
                  });
                  //NAVIGATE AFTER FIREBASE LOGIC
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (ctx) => const LocationAccess()));
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     builder: (ctx) => const PersonInfo(isEdit: false,)));
                },
                style: ElevatedButton.styleFrom(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  primary: Colors.pink,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
