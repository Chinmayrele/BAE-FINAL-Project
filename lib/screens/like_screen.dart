import 'package:bae_dating_app/screens/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/color_constants.dart';
import '../models/user_info.dart';
import '../providers/info_provider.dart';

/*
Title:LikesScreen
Purpose:LikesScreen
Created By:Chinmay Rele
*/

class LikesScreen extends StatefulWidget {
  const LikesScreen({Key? key}) : super(key: key);
  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesScreen> {
  late InfoProviders result;
  late List<dynamic> userInf;
  late bool isSubscribed;
  List<UserInfos> likeData = [];
  bool isLoading = true;
  @override
  void initState() {
    // debugPrint("INTI STATE OF LIKE SCREEN IS CALLED>>>>>>");
    result = Provider.of<InfoProviders>(context, listen: false);
    result.fetchUSerProfileData().then((value) {
      userInf = result.userInfo[0].whoLikedMe;
      isSubscribed = result.userInfo[0].isSubscribed;
      if (userInf.isEmpty) {
        setState(() {
          isLoading = false;
        });
      }
      for (int i = 0; i < userInf.length; i++) {
        result.fetchSingleUserData(userInf[i]).then((value) {
          likeData.add(value);
          setState(() {
            isLoading = false;
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: ColorConstants.kWhite,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : getBody(),
        // bottomSheet: getFooter(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.only(left: size.width * 0.1),
                child: const Text(
                  "See who liked you",
                  style: TextStyle(
                    fontSize: 22,
                    color: ColorConstants.kWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Center(
              //   child: Text(
              //     "Top Picks",
              //     style: TextStyle(
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold,
              //       color: ColorConstants.kWhite.withOpacity(0.7),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1.2,
          endIndent: size.width * 0.03,
          indent: size.width * 0.03,
          color: Colors.white24,
        ),
        const SizedBox(height: 12),
        likeData.isEmpty
            ? Column(
                children: [
                  SizedBox(height: size.height * 0.35),
                  const Center(
                    child: Text(
                      'Looks like no one liked you!!!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ],
              )
            : !isSubscribed
                ? const Center(child: SubscriptionPage())
                : Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 20,
                      children: List.generate(likeData.length, (index) {
                        return SizedBox(
                          width: (size.width - 25) / 2,
                          height: 250,
                          child: Stack(
                            children: [
                              Container(
                                width: (size.width - 15) / 2,
                                height: 250,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            (likeData[index].imageUrls[0])),
                                        fit: BoxFit.cover)),
                              ),
                              Positioned(
                                top: 150,
                                child: Container(
                                  width: (size.width - 15) / 2,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.red.withOpacity(0.55),
                                            Colors.red.withOpacity(0),
                                          ],
                                          end: Alignment.topCenter,
                                          begin: Alignment.bottomCenter)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // likes_json[index]['active']
                                      //     ? Padding(
                                      //         padding: const EdgeInsets.only(
                                      //             left: 8, bottom: 8),
                                      //         child: Row(
                                      //           children: [
                                      //             Container(
                                      //               width: 8,
                                      //               height: 8,
                                      //               decoration:
                                      //                   const BoxDecoration(
                                      //                 color:
                                      //                     ColorConstants.kGreen,
                                      //                 shape: BoxShape.circle,
                                      //               ),
                                      //             ),
                                      //             const SizedBox(
                                      //               width: 5,
                                      //             ),
                                      //             const Text(
                                      //               "Recently Active",
                                      //               style: TextStyle(
                                      //                 color:
                                      //                     ColorConstants.kWhite,
                                      //                 fontSize: 14,
                                      //               ),
                                      //             )
                                      //           ],
                                      //         ),
                                      //       )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, bottom: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: ColorConstants.kGrey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              likeData[index].name,
                                              style: const TextStyle(
                                                color: ColorConstants.kWhite,
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  )
      ],
    );
  }
}
