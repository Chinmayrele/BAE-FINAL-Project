import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../global/profile_list.dart';
import '../global/title_text.dart';
import '../models/user_info.dart';
import '../providers/info_provider.dart';
import '../screens/home_page_screen.dart';
import '../shared_preferences/user_values.dart';

class UserInfoForm extends StatefulWidget {
  final bool isEdit;
  // final double latitude;
  // final double longitude;
  const UserInfoForm({
    Key? key,
    required this.isEdit,
    // this.latitude = 0,
    // this.longitude = 0,
  }) : super(key: key);

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  late InfoProviders profileUserInfo;
  final _form = GlobalKey<FormState>();
  String? _selectedGender;
  String? _genderPreference;
  String? _selectedAge;
  File? _imageFile;
  UploadTask? task;
  List<dynamic> imageUrlsUser = [];
  bool isLoading = false;
  double? latitude;
  double? longitude;
  var locationMessage = '';
  bool isLocLoading = true;
  bool isAlreadyLoading = false;
  late UserInfos alreadyResult;
  var urlDownload = '';
  bool isImageLoader = false;

  snackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  var _editedProfile = UserInfos(
    userId: FirebaseAuth.instance.currentUser!.uid,
    name: '',
    email: '',
    phoneNo: '',
    gender: '',
    genderChoice: '',
    iLike: [],
    isViewed: [],
    whoLikedMe: [],
    intersectionLikes: [],
    latitude: 0,
    longitude: 0,
    age: 0,
    about: '',
    interest: '',
    address: '',
    imageUrls: [],
    isSubscribed: false,
  );

  Future<void> getPicture() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageTemp = File(image.path);
        setState(() {
          _imageFile = imageTemp;
        });
      }
    } on PlatformException catch (err) {
      //debugPrint('Failed to Pick up the Image: $err');
    }
  }

  Future<void> convertToUrl() async {
    try {
      if (_imageFile != null) {
        final fileName = _imageFile!.path;
        final destination = 'files/$fileName';
        final ref = FirebaseStorage.instance.ref(destination);
        task = ref.putFile(_imageFile!);
        if (task == null) {
          return;
        }
        final snapshot = await task!.whenComplete(() {});
        urlDownload = await snapshot.ref.getDownloadURL();
        setState(() {});
      }
    } on FirebaseException catch (e) {
      //debugPrint('Error Uploading: $e');
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      isLocLoading = true;
    });
    bool serviceEnable;
    LocationPermission permission;
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      await Geolocator.openLocationSettings();
      return Future.error('Location Service are Disabled!');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission Error has been Denied!');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location Permission are permanently denied, We cannot request permissions');
    }
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // var lastPosition = await Geolocator.getLastKnownPosition();
    // await setLocationFlag(
    //     latitude: position.latitude, longitude: position.longitude);

    setState(() {
      locationMessage = '${position.latitude}, ${position.longitude}';
      latitude = position.latitude;
      longitude = position.longitude;
      isLocLoading = false;
    });
  }

  void saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    //Firebase Logic
    //FIREBASE IMAGE STORAGE LOGIC
    if (urlDownload.isEmpty) {
      snackBar('Please Select a image first');
    } else {
      try {
        setState(() {
          isLoading = true;
        });
        // if (_imageFile != null) {
        await convertToUrl();
        // final fileName = _imageFile!.path;
        // final destination = 'files/$fileName';
        // final ref = FirebaseStorage.instance.ref(destination);
        // task = ref.putFile(_imageFile!);
        // if (task != null) {
        //   final snapshot = await task!.whenComplete(() {});
        //   urlDownload = await snapshot.ref.getDownloadURL();
        //debugPrint('DOWNLOAD URL: $urlDownload');
        // await _getLocation();
        if (widget.isEdit) {
          imageUrlsUser.removeAt(0);
          imageUrlsUser.insert(0, urlDownload);
        } else {
          imageUrlsUser.add(urlDownload);
        }
        _editedProfile = UserInfos(
          userId: _editedProfile.userId,
          name: _editedProfile.name,
          email: _editedProfile.email,
          phoneNo: _editedProfile.phoneNo,
          gender: _editedProfile.gender,
          genderChoice: _editedProfile.genderChoice,
          iLike: _editedProfile.iLike,
          isViewed: _editedProfile.isViewed,
          whoLikedMe: _editedProfile.whoLikedMe,
          intersectionLikes: _editedProfile.intersectionLikes,
          latitude: latitude as double,
          longitude: longitude as double,
          age: _editedProfile.age,
          about: _editedProfile.about,
          interest: _editedProfile.interest,
          address: _editedProfile.address,
          imageUrls: imageUrlsUser,
          isSubscribed: _editedProfile.isSubscribed,
        );
        await profileUserInfo.addUserProfileInfo(_editedProfile);
        await setVisitingFlag(
          isProfileDone: true,
          isLocDone: true,
        );
        setState(() {
          isLoading = false;
        });
        //Navigate after Completeing Firebase Logic
        widget.isEdit
            ? Navigator.of(context).pop()
            : Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const HomePageScreen()));
        // }
        if (task == null) {
          return;
        }
        // }
      } on FirebaseException catch (e) {
        //debugPrint('Error Uploading: $e');
      }
    }
  }

  @override
  void initState() {
    if (widget.isEdit) {
      setState(() {
        isAlreadyLoading = true;
      });
      FirebaseFirestore.instance
          .collection('profile')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        final e = value.data();
        alreadyResult = UserInfos(
          userId: e!['userId'] ?? '',
          name: e['name'] ?? '',
          email: e['email'] ?? '',
          phoneNo: e['phoneNo'] ?? '',
          gender: e['gender'] ?? '',
          genderChoice: e['genderChoice'] ?? '',
          iLike: e['iLike'] ?? [],
          isViewed: e['isViewed'] ?? [],
          whoLikedMe: e['whoLikedMe'] ?? [],
          intersectionLikes: e['intersectionLikes'] ?? [],
          latitude: e['latitude'] ?? 0,
          longitude: e['longitude'] ?? 0,
          age: e['age'] ?? 0,
          about: e['about'] ?? '',
          interest: e['interest'] ?? '',
          address: e['address'] ?? '',
          imageUrls: e['imageUrls'] ?? [],
          isSubscribed: e['isSubscribed'] ?? false,
        );
        imageUrlsUser = alreadyResult.imageUrls;
        _selectedAge = alreadyResult.age.toString();
        _selectedGender = alreadyResult.gender;
        _genderPreference = alreadyResult.genderChoice;
        urlDownload = alreadyResult.imageUrls[0];
        setState(() {
          isAlreadyLoading = false;
        });
      });
    }
    _getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileUserInfo = Provider.of<InfoProviders>(context, listen: false);
    return widget.isEdit
        ? isLocLoading && isAlreadyLoading
            ? Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : getContainer()
        : isLocLoading
            ? Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : getContainer();
  }

  getContainer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.5,
                    color: Colors.white,
                  ),
                ),
                child: urlDownload.isNotEmpty
                    ? GestureDetector(
                        onTap: () async {
                          setState(() {
                            isImageLoader = true;
                          });
                          await getPicture();
                          await convertToUrl();
                          setState(() {
                            isImageLoader = false;
                          });
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(130),
                              child: Container(
                                  height: 130,
                                  width: 130,
                                  decoration: const BoxDecoration(
                                    color: Colors.white12,
                                    shape: BoxShape.circle,
                                    // image: !widget.isEdit
                                    //     ? DecorationImage(
                                    //         image: Image.file(_imageFile!).image,
                                    //         fit: BoxFit.cover,
                                    //       )
                                  ),
                                  child: isImageLoader
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : Image.network(
                                          urlDownload,
                                          fit: BoxFit.cover,
                                        )),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: FloatingActionButton(
                                onPressed: () {
                                  // await getPicture();
                                  // await convertToUrl();
                                },
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.pink[700],
                              ),
                            ),
                          ],
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          await getPicture();
                          await convertToUrl();
                        },
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.pink[400],
                            size: 34,
                          ),
                        ),
                      ),
              ),
            ),
            titleText('Full Name', true),
            TextFormField(
              initialValue: widget.isEdit ? alreadyResult.name : '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorHeight: 22,
              cursorColor: Colors.pink,
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
                hintText: 'Name',
                hintStyle: const TextStyle(
                    color: Colors.white24, fontSize: 15, wordSpacing: 2),
                fillColor: Colors.white24,
                filled: true,
                // suffixIcon: const Icon(Icons.mic, color: Colors.grey),
              ),
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Please Enter Your Name';
                }
                return null;
              },
              onSaved: (val) {
                _editedProfile = UserInfos(
                  userId: _editedProfile.userId,
                  name: val.toString(),
                  email: _editedProfile.email,
                  phoneNo: _editedProfile.phoneNo,
                  gender: _editedProfile.gender,
                  genderChoice: _editedProfile.genderChoice,
                  iLike: _editedProfile.iLike,
                  isViewed: _editedProfile.isViewed,
                  whoLikedMe: _editedProfile.whoLikedMe,
                  intersectionLikes: _editedProfile.intersectionLikes,
                  latitude: _editedProfile.latitude,
                  longitude: _editedProfile.longitude,
                  age: _editedProfile.age,
                  about: _editedProfile.about,
                  interest: _editedProfile.interest,
                  address: _editedProfile.address,
                  imageUrls: _editedProfile.imageUrls,
                  isSubscribed: _editedProfile.isSubscribed,
                );
              },
            ),
            titleText('Email', true),
            TextFormField(
              initialValue: widget.isEdit ? alreadyResult.email : '',
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
              onSaved: (val) {
                _editedProfile = UserInfos(
                  userId: _editedProfile.userId,
                  name: _editedProfile.name,
                  email: val.toString(),
                  phoneNo: _editedProfile.phoneNo,
                  gender: _editedProfile.gender,
                  genderChoice: _editedProfile.genderChoice,
                  iLike: _editedProfile.iLike,
                  isViewed: _editedProfile.isViewed,
                  whoLikedMe: _editedProfile.whoLikedMe,
                  intersectionLikes: _editedProfile.intersectionLikes,
                  latitude: _editedProfile.latitude,
                  longitude: _editedProfile.longitude,
                  age: _editedProfile.age,
                  about: _editedProfile.about,
                  interest: _editedProfile.interest,
                  address: _editedProfile.address,
                  imageUrls: _editedProfile.imageUrls,
                  isSubscribed: _editedProfile.isSubscribed,
                );
              },
            ),
            titleText('Phone Number', true),
            TextFormField(
              initialValue: widget.isEdit ? alreadyResult.phoneNo : '',
              autovalidateMode: AutovalidateMode.disabled,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              // controller: _mySearched,
              cursorHeight: 22,
              // autofocus: true,
              cursorColor: Colors.pink,
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                hintText: 'Phone Number',
                hintStyle: const TextStyle(
                    color: Colors.white24, fontSize: 15, wordSpacing: 2),
                fillColor: Colors.white24,
                filled: true,
                suffixIcon: const Icon(Icons.phone, color: Colors.grey),
              ),
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Please Enter a Your Mobile No.';
                } else if (val.length != 10) {
                  return 'Please Enter a Valid Mobile Number';
                }
                return null;
              },
              onSaved: (val) {
                _editedProfile = UserInfos(
                  userId: _editedProfile.userId,
                  name: _editedProfile.name,
                  email: _editedProfile.email,
                  phoneNo: val.toString(),
                  gender: _editedProfile.gender,
                  genderChoice: _editedProfile.genderChoice,
                  iLike: _editedProfile.iLike,
                  isViewed: _editedProfile.isViewed,
                  whoLikedMe: _editedProfile.whoLikedMe,
                  intersectionLikes: _editedProfile.intersectionLikes,
                  latitude: _editedProfile.latitude,
                  longitude: _editedProfile.longitude,
                  age: _editedProfile.age,
                  about: _editedProfile.about,
                  interest: _editedProfile.interest,
                  address: _editedProfile.address,
                  imageUrls: _editedProfile.imageUrls,
                  isSubscribed: _editedProfile.isSubscribed,
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText('Gender', true),
                    SizedBox(
                      width: 150,
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
                                  'Gender',
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
                          items: items
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
                          value: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value as String;
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
                          dropdownWidth: 150,
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
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText('Age', true),
                    SizedBox(
                      width: 160,
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
                                  'Age',
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
                          items: ages
                              .map((age) => DropdownMenuItem<String>(
                                    value: age,
                                    child: Text(
                                      age,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: _selectedAge,
                          onChanged: (val) {
                            setState(() {
                              _selectedAge = val as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          iconSize: 24,
                          iconEnabledColor: Colors.grey,
                          iconDisabledColor: Colors.white24,
                          buttonHeight: 48,
                          buttonWidth: 160,
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
                          dropdownMaxHeight: 140,
                          dropdownWidth: 150,
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
                  ],
                )
              ],
            ),
            titleText('About', false),
            TextFormField(
              initialValue: widget.isEdit ? alreadyResult.about : '',
              maxLines: null,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              // controller: _mySearched,
              cursorHeight: 22,
              // autofocus: true,
              cursorColor: Colors.pink,
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
                contentPadding: const EdgeInsets.only(
                    left: 25, top: 6, bottom: 6, right: 15),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.pink, width: 2),
                    borderRadius: BorderRadius.circular(30)),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: 'About',
                hintStyle: const TextStyle(
                    color: Colors.white24, fontSize: 15, wordSpacing: 2),
                fillColor: Colors.white24,
                filled: true,
                // suffixIcon: const Icon(Icons.mic, color: Colors.grey),
              ),
              onSaved: (val) {
                _editedProfile = UserInfos(
                  userId: _editedProfile.userId,
                  name: _editedProfile.name,
                  email: _editedProfile.email,
                  phoneNo: _editedProfile.phoneNo,
                  gender: _editedProfile.gender,
                  genderChoice: _editedProfile.genderChoice,
                  iLike: _editedProfile.iLike,
                  isViewed: _editedProfile.isViewed,
                  whoLikedMe: _editedProfile.whoLikedMe,
                  intersectionLikes: _editedProfile.intersectionLikes,
                  latitude: _editedProfile.latitude,
                  longitude: _editedProfile.longitude,
                  age: _editedProfile.age,
                  about: val.toString(),
                  interest: _editedProfile.interest,
                  address: _editedProfile.address,
                  imageUrls: _editedProfile.imageUrls,
                  isSubscribed: _editedProfile.isSubscribed,
                );
              },
            ),
            titleText('Who would you like to date', true),
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
                          'Date Preference',
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
                  items: items
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
                  value: _genderPreference,
                  onChanged: (value) {
                    setState(() {
                      _genderPreference = value as String;
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
                  buttonPadding: const EdgeInsets.only(left: 24, right: 14),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.pink, width: 2),
                    color: Colors.white24,
                  ),
                  buttonElevation: 2,
                  itemHeight: 40,
                  itemPadding: const EdgeInsets.only(left: 14, right: 14),
                  dropdownMaxHeight: 200,
                  dropdownWidth: MediaQuery.of(context).size.width * 0.92,
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
            titleText('Interest', true),
            TextFormField(
              initialValue: widget.isEdit ? alreadyResult.interest : '',
              maxLines: null,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              // controller: _mySearched,
              cursorHeight: 22,
              // autofocus: true,
              cursorColor: Colors.pink,
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
                hintText: 'Interest',
                hintStyle: const TextStyle(
                    color: Colors.white24, fontSize: 15, wordSpacing: 2),
                fillColor: Colors.white24,
                filled: true,
                suffixIcon: const Icon(Icons.edit, color: Colors.grey),
              ),
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Please Enter Your Interests';
                }
                return null;
              },
              onSaved: (val) {
                _editedProfile = UserInfos(
                  userId: _editedProfile.userId,
                  name: _editedProfile.name,
                  email: _editedProfile.email,
                  phoneNo: _editedProfile.phoneNo,
                  gender: _editedProfile.gender,
                  genderChoice: _editedProfile.genderChoice,
                  iLike: _editedProfile.iLike,
                  isViewed: _editedProfile.isViewed,
                  whoLikedMe: _editedProfile.whoLikedMe,
                  intersectionLikes: _editedProfile.intersectionLikes,
                  latitude: _editedProfile.latitude,
                  longitude: _editedProfile.longitude,
                  age: _editedProfile.age,
                  about: _editedProfile.about,
                  interest: val.toString(),
                  address: _editedProfile.address,
                  imageUrls: _editedProfile.imageUrls,
                  isSubscribed: _editedProfile.isSubscribed,
                );
              },
            ),
            titleText('City', false),
            TextFormField(
              initialValue: widget.isEdit ? alreadyResult.address : '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              // controller: _mySearched,
              cursorHeight: 22,
              // autofocus: true,
              cursorColor: Colors.pink,
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
                hintText: 'City',
                hintStyle: const TextStyle(
                    color: Colors.white24, fontSize: 15, wordSpacing: 2),
                fillColor: Colors.white24,
                filled: true,
                suffixIcon: const Icon(Icons.location_on, color: Colors.grey),
              ),
              onSaved: (val) {
                _editedProfile = UserInfos(
                  userId: _editedProfile.userId,
                  name: _editedProfile.name,
                  email: _editedProfile.email,
                  phoneNo: _editedProfile.phoneNo,
                  gender: _editedProfile.gender,
                  genderChoice: _editedProfile.genderChoice,
                  iLike: _editedProfile.iLike,
                  isViewed: _editedProfile.isViewed,
                  whoLikedMe: _editedProfile.whoLikedMe,
                  intersectionLikes: _editedProfile.intersectionLikes,
                  latitude: _editedProfile.latitude,
                  longitude: _editedProfile.longitude,
                  age: _editedProfile.age,
                  about: _editedProfile.about,
                  interest: _editedProfile.interest,
                  address: val.toString(),
                  imageUrls: _editedProfile.imageUrls,
                  isSubscribed: _editedProfile.isSubscribed,
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: ElevatedButton(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                onPressed: () {
                  _editedProfile = UserInfos(
                    userId: _editedProfile.userId,
                    name: _editedProfile.name,
                    email: _editedProfile.email,
                    phoneNo: _editedProfile.phoneNo,
                    gender: _selectedGender.toString(),
                    genderChoice: _genderPreference.toString(),
                    iLike: _editedProfile.iLike,
                    isViewed: _editedProfile.isViewed,
                    whoLikedMe: _editedProfile.whoLikedMe,
                    intersectionLikes: _editedProfile.intersectionLikes,
                    latitude: latitude as double,
                    longitude: longitude as double,
                    age: int.parse(_selectedAge.toString()),
                    about: _editedProfile.about,
                    interest: _editedProfile.interest,
                    address: _editedProfile.address,
                    imageUrls: _editedProfile.imageUrls,
                    isSubscribed: _editedProfile.isSubscribed,
                  );
                  saveForm();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  primary: Colors.pink,
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
