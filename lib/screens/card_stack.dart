import 'package:bae_dating_app/screens/subscription_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/drag_widget.dart';
import '../models/user_info.dart';
import '../providers/info_provider.dart';

class CardsStackWidget extends StatefulWidget {
  const CardsStackWidget({Key? key}) : super(key: key);

  @override
  State<CardsStackWidget> createState() => _CardsStackWidgetState();
}

class _CardsStackWidgetState extends State<CardsStackWidget> {
  late InfoProviders result;
  late List<UserInfos> userProfileDataResult;
  late List<UserInfos> usersDataResult;
  bool isLoading = true;
  bool isUpdateLoad = true;
  int countLikes = 0;
  List<dynamic> iLike = [];
  List isViewed = [];
  List whoLikedMe = [];
  List intersectionOfLikes = [];
  late bool isSubscribedUser;

  List<UserInfos> dragabbleItems = [];
  int itemLength = 0;

  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);

  @override
  void initState() {
    // print("ID FIRST PAGE: ${FirebaseAuth.instance.currentUser!.uid}");
    // debugPrint("INIT STATE OF CARD STACK CALLED");
    result = Provider.of<InfoProviders>(context, listen: false);
    result.fetchUSerProfileData().then((_) {
      userProfileDataResult = result.userInfo;
      iLike = userProfileDataResult[0].iLike;
      isSubscribedUser = userProfileDataResult[0].isSubscribed;
      isViewed = userProfileDataResult[0].isViewed;
      whoLikedMe = userProfileDataResult[0].whoLikedMe;
      intersectionOfLikes = userProfileDataResult[0].intersectionLikes;
      result
          .fetchUsersData(
        userProfileDataResult[0].genderChoice,
        userProfileDataResult[0].latitude,
        userProfileDataResult[0].longitude,
      )
          .then((_) {
        //debugPrint('FETCH USER DATA ENTER THEN VALUE');
        dragabbleItems = result.usersData;

        if (dragabbleItems.isNotEmpty &&
            dragabbleItems[0].userId != 'zzzzzzzzzzzzzzzzzzzz') {
          dragabbleItems.insert(
              0,
              UserInfos(
                  userId: 'zzzzzzzzzzzzzzzzzzzz',
                  name: '',
                  email: 'email',
                  phoneNo: 'phoneNo',
                  gender: 'gender',
                  genderChoice: 'genderChoice',
                  age: 0,
                  isViewed: [],
                  whoLikedMe: [],
                  iLike: [],
                  intersectionLikes: [],
                  latitude: 0,
                  longitude: 0,
                  about: 'about',
                  interest: 'interest',
                  address: 'address',
                  imageUrls: [],
                  isSubscribed: false));
        }
        itemLength = result.usersData.length;
        //debugPrint("ITEM LENGTH: $itemLength");
        setState(() {
          isLoading = false;
        });
      });
      // setState(() {
      // itemsTemp = explore_json;
      // itemLength = explore_json.length;
    });
    super.initState();
  }

  @override
  void dispose() {
    userProfileDataResult = [];
    iLike = [];
    isViewed = [];
    whoLikedMe = [];
    intersectionOfLikes = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    countLikes = iLike.length;
    for (var i in iLike) {
      for (var j in whoLikedMe) {
        if (i == j) {
          if (!intersectionOfLikes.contains(i)) {
            intersectionOfLikes.add(i);
            FirebaseFirestore.instance
                .collection('profile')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              "intersectionLikes": intersectionOfLikes,
            }).then((_) {
              isUpdateLoad = false;
            });
          }
        }
      }
    }
    // if (!isLoading && !isUpdateLoad) {
    //   if (dragabbleItems[dragabbleItems.length - 1].userId !=
    //       'zzzzzzzzzzzzzzzzzzzz') {
    //     dragabbleItems.add(UserInfos(
    //         userId: 'zzzzzzzzzzzzzzzzzzzz',
    //         name: 'name',
    //         email: 'email',
    //         phoneNo: 'phoneNo',
    //         gender: 'gender',
    //         genderChoice: 'genderChoice',
    //         age: 0,
    //         isViewed: [],
    //         whoLikedMe: [],
    //         iLike: [],
    //         intersectionLikes: [],
    //         latitude: 0,
    //         longitude: 0,
    //         about: 'about',
    //         interest: 'interest',
    //         address: 'address',
    //         imageUrls: [],
    //         isSubscribed: false));
    //   }
    // }
    //debugPrint("LENGTH OF DRAGGABLE ITEMS IN BUILD: ${dragabbleItems.length}");
    return SafeArea(
      child: Scaffold(
          body: (isLoading && isUpdateLoad)
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : getBody()),
    );
  }

  Widget getBody() {
    // //debugPrint("NAME IN BUILD NOWW: ${dragabbleItems[0].name}");
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        // SizedBox(height: size.height * 0.06),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                  text: 'Find People Who Can ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                  children: [
                    TextSpan(
                      text: '𝓜𝓪𝓽𝓬𝓱',
                      style: TextStyle(color: Colors.pink, fontSize: 22),
                    ),
                    TextSpan(
                      text: ' With You',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ])),
        ),
        SizedBox(height: size.height * 0.02),
        dragabbleItems.isEmpty
            ? Column(
                children: [
                  SizedBox(height: size.height * 0.34),
                  Container(
                    margin: const EdgeInsets.all(10),
                    width: size.width * 0.95,
                    child: const Center(
                      child: Text(
                        'Looks like we found no one around you!!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                    ),
                  ),
                ],
              )
            // const Center(
            //     child: Text(
            //       'Looks Like we found no One around you',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 24,
            //       ),
            //     ),
            //   )
            : countLikes >= 4 && !isSubscribedUser
                ? const Center(child: SubscriptionPage())
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ValueListenableBuilder(
                          valueListenable: swipeNotifier,
                          builder: (context, swipe, _) => Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children:
                                List.generate(dragabbleItems.length, (index) {
                              return DragWidget(
                                  profile: dragabbleItems[index],
                                  index: index,
                                  swipeNotifier: swipeNotifier,
                                  iLike: iLike,
                                  isViewed: isViewed,
                                  whoLikedMe: whoLikedMe,
                                  intersectionOfLikes: intersectionOfLikes,
                                  length: dragabbleItems.length);
                            }),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: DragTarget<int>(
                          builder: (
                            BuildContext context,
                            List<dynamic> accepted,
                            List<dynamic> rejected,
                          ) {
                            return IgnorePointer(
                              child: Container(
                                height: 700.0,
                                width: 80.0,
                                color: Colors.transparent,
                              ),
                            );
                          },
                          onAccept: (int index) {
                            setState(() {
                              dragabbleItems.removeAt(index);
                            });
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: DragTarget<int>(
                          builder: (
                            BuildContext context,
                            List<dynamic> accepted,
                            List<dynamic> rejected,
                          ) {
                            return IgnorePointer(
                              child: Container(
                                height: 700.0,
                                width: 80.0,
                                color: Colors.transparent,
                              ),
                            );
                          },
                          onAccept: (int index) {
                            setState(() {
                              dragabbleItems.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
      ],
    );
  }
}
