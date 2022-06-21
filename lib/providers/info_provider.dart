import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/que_ans_info.dart';
import '../models/user_info.dart';

class InfoProviders with ChangeNotifier {
  final List<UserInfos> _userInfo = [];
  final List<UserInfos> _usersData = [];
  // late UserInfos _userData;
  final List<QueAnsInfo> _queAnsInfo = [];
  bool call_type = false;

  List<UserInfos> get userInfo => [..._userInfo];
  List<UserInfos> get usersData => [..._usersData];
  // UserInfos get userData => _userData;
  List<QueAnsInfo> get queAnsInfo => [..._queAnsInfo];

  Future<void> addUserProfileInfo(UserInfos info) async {
    await FirebaseFirestore.instance
        .collection('profile')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'isProfileComplete': true,
      'userId': info.userId,
      'name': info.name,
      'email': info.email,
      "phoneNo": info.phoneNo,
      "gender": info.gender,
      "genderChoice": info.genderChoice,
      "iLike": info.iLike,
      "isViewed": info.isViewed,
      "whoLikedMe": info.whoLikedMe,
      "intersectionLikes": info.intersectionLikes,
      "latitude": info.latitude,
      "longitude": info.longitude,
      "age": info.age,
      "about": info.about,
      "interest": info.interest,
      "address": info.address,
      "imageUrls": info.imageUrls,
      "isSubscribed": info.isSubscribed,
    });
    notifyListeners();
  }

  Future<void> addQueAnsInfo(QueAnsInfo info) async {
    await FirebaseFirestore.instance
        .collection('profile')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('queAnsSec')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "relationStatus": info.relationStatus,
      "vacationStatus": info.vacationStatus,
      "nightStatus": info.nightStatus,
      "smokeStatus": info.smokeStatus,
      "drinkStatus": info.drinkStatus,
      "exerciseStatus": info.exerciseStatus,
      "heightStatus": info.heightStatus,
    });
    // _queAnsInfo.add(info);
    notifyListeners();
  }

  Future<UserInfos> fetchSingleUserData(String userID) async {
    //debugPrint('USER ID FETCHING...');
    final data = await FirebaseFirestore.instance
        .collection('profile')
        .doc(userID)
        .get();
    final e = data.data();
    final userDatas = UserInfos(
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
    return userDatas;
  }

  Future<void> fetchUsersData(
      String genderPreference, double lati, double longi) async {
    //debugPrint('12342353464565786786756545756585857857');
    final data = await FirebaseFirestore.instance.collection('profile').get();
    //debugPrint("DATA SIZE IMP: ${data.size}");
    // debugPrint("DATA DOCS LENGTH: ${data.docs.length}");
    final e = data.docs;
    _usersData.clear();
    for (int i = 0; i < e.length; i++) {
      if (!e[i].data().containsKey('userId')) {
        continue;
      } else {
        // print("USER DATA ID: ${e[i]['userId']}");
        final us = UserInfos(
            userId: e[i]['userId'] ?? '',
            name: e[i]['name'] ?? '',
            email: e[i]['email'] ?? '',
            phoneNo: e[i]['phoneNo'] ?? '',
            gender: e[i]['gender'] ?? '',
            genderChoice: e[i]['genderChoice'] ?? '',
            iLike: e[i]['iLike'] ?? [],
            isViewed: e[i]['isViewed'] ?? [],
            whoLikedMe: e[i]['whoLikedMe'] ?? [],
            intersectionLikes: e[i]['intersectionLikes'] ?? [],
            latitude: e[i]['latitude'] ?? 0,
            longitude: e[i]['longitude'] ?? 0,
            age: e[i]['age'] ?? 0,
            about: e[i]['about'] ?? '',
            interest: e[i]['interest'] ?? '',
            address: e[i]['address'] ?? '',
            imageUrls: e[i]['imageUrls'] ?? [],
            isSubscribed: e[i]['isSubscribed'] ?? false);
        final distance =
            Geolocator.distanceBetween(lati, longi, us.latitude, us.longitude);
        //  IF GENDER && YOURSELF REMOVE CONDITION   && !_userInfo[0].isViewed.contains(us.userId)
        if (us.userId.isNotEmpty &&
            us.gender.toLowerCase() == genderPreference.toLowerCase() &&
            us.userId != FirebaseAuth.instance.currentUser!.uid &&
            distance < 150000 &&
            !_userInfo[0].isViewed.contains(us.userId)) {
          _usersData.add(us);
        }
      }
      notifyListeners();
    }
  }

  Future<QueAnsInfo> fetchQueAnsData(String useId) async {
    //debugPrint('12342353464565786786756545756585857857');
    final data = await FirebaseFirestore.instance
        .collection('profile')
        .doc(useId)
        .collection('queAnsSec')
        .doc(useId)
        .get();
    final e = data.data();

    final userInf = QueAnsInfo(
      relationStatus: e!['relationStatus'] ?? '',
      vacationStatus: e['vacationStatus'] ?? '',
      exerciseStatus: e['exerciseStatus'] ?? '',
      smokeStatus: e['smokeStatus'] ?? '',
      drinkStatus: e['drinkStatus'] ?? '',
      nightStatus: e['nightStatus'] ?? '',
      heightStatus: e['heightStatus'] ?? '',
    );
    return userInf;
  }

  Future<void> fetchUSerProfileData() async {
    final data = await FirebaseFirestore.instance
        .collection('profile')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final e = data.data();
    // print("ID IN PROVIDER TOKEN: ${e!['userId']}");
    final userInf = UserInfos(
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
      imageUrls: e['imageUrls'],
      isSubscribed: e['isSubscribed'] ?? false,
    );
    _userInfo.clear();
    _userInfo.add(userInf);
    //debugPrint("FETCH PROFILE USER DATA PROVIDER NAME: ${_userInfo[0].name}");
    notifyListeners();
  }

  bool checkAudioVideo(bool value) {
    call_type = value;
    return call_type;
  }
}
