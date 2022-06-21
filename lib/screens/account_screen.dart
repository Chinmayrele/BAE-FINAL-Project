import 'dart:io';

import 'package:bae_dating_app/screens/person_info.dart';
import 'package:bae_dating_app/screens/splash_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../common/color_constants.dart';
import '../data/payment_integrate.dart';
import '../models/user_info.dart';
import '../providers/info_provider.dart';
import '../shared_preferences/user_values.dart';

/*
Title:AccountScreen
Purpose:AccountScreen
Created By:Chinmay Rele
*/

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late InfoProviders result;
  late List<UserInfos> userData;
  bool isLoading = true;
  List<dynamic> imageUser = [];

  @override
  void initState() {
    // debugPrint("INIT STATE OF ACCOUNT SCREEN CALLED.....");
    result = Provider.of<InfoProviders>(context, listen: false);
    result.fetchUSerProfileData().then((value) {
      setState(() {
        userData = result.userInfo;
        imageUser = userData[0].imageUrls;
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: ColorConstants.kGrey.withOpacity(0.2),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              ))
            : getBody(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          ClipPath(
            // clipper: OvalBottomBorderClipper(),
            child: Container(
              width: size.width,
              height: size.height * 0.5,
              decoration: BoxDecoration(color: Colors.white38, boxShadow: [
                BoxShadow(
                  color: ColorConstants.kGrey.withOpacity(0.1),
                  spreadRadius: 10,
                  blurRadius: 10,
                  // changes position of shadow
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      // decoration: const BoxDecoration(
                      //   shape: BoxShape.circle,
                      // ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.pink),
                            ),
                            width: 180.0,
                            height: 180.0,
                            padding: const EdgeInsets.all(70.0),
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          errorWidget: (context, url, error) => Material(
                            child: Image.asset(
                              "images/img_not_available.jpeg",
                              width: 180.0,
                              height: 180.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                            clipBehavior: Clip.hardEdge,
                          ),
                          imageUrl: userData[0].imageUrls[0],
                          width: 180.0,
                          height: 180.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      userData[0].name + ", " + userData[0].age.toString(),
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        const PaymentIntegrate()));
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstants.kWhite,
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ColorConstants.kGrey.withOpacity(0.1),
                                      spreadRadius: 10,
                                      blurRadius: 15,
                                      // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.workspace_premium_outlined,
                                  size: 35,
                                  color: ColorConstants.kBlack.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Go Premium",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.kBlack.withOpacity(0.8),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 10),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) =>
                                          PersonInfo(isEdit: true)));
                                },
                                child: SizedBox(
                                  width: 85,
                                  height: 85,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorConstants.primary_one,
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorConstants.kPrimary
                                                  .withOpacity(0.15),
                                              spreadRadius: 10,
                                              blurRadius: 15,
                                              // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "EDIT INFO",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        ColorConstants.kBlack.withOpacity(0.8)),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await setVisitingFlag(
                                    isLocDone: false,
                                    isLoginDone: false,
                                    isProfileDone: false,
                                    isQueAnsDone: false);
                                await _signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (ctx) => const SplashScreen()),
                                    (Route route) => false);
                                setState(() {});
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  color: ColorConstants.kWhite,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ColorConstants.kGrey.withOpacity(0.1),
                                      spreadRadius: 10,
                                      blurRadius: 15,
                                      // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.logout,
                                  size: 35,
                                  color: ColorConstants.kBlack.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "LOG OUT",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.kBlack.withOpacity(0.8),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ImageContainer(imageList: imageUser),
        ],
      ),
    );
  }
}

class ImageContainer extends StatefulWidget {
  final List<dynamic> imageList;
  const ImageContainer({Key? key, required this.imageList}) : super(key: key);

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  bool isLoading = true;
  String urlDownload = '';
  File? _imageFile;
  UploadTask? task;
  // List<dynamic> imageUrlsUser = [];
  late Map<String, dynamic> list;
  bool isLoad = true;
  // late InfoProviders result;

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
        //debugPrint('DOWNLOAD URL: $urlDownload');
        widget.imageList.add(urlDownload);
        // imageUrlsUser.add(urlDownload);
        FirebaseFirestore.instance
            .collection('profile')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'imageUrls': widget.imageList,
        });
        setState(() {});
      }
    } on FirebaseException catch (e) {
      //debugPrint('Error Uploading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int x = 4 - widget.imageList.length;

    return Wrap(
      children: [
        ...List.generate(widget.imageList.length - 1,
            (index) => buildBorderBox(widget.imageList[index + 1])),
        ...List.generate(x + 1, ((index) => buildBorderBox(''))),
      ],
    );
  }

  buildBorderBox(String url) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
        strokeWidth: 2,
        dashPattern: const [6, 6],
        color: Colors.white,
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(6),
        child: InkWell(
          onTap: () async {
            await getPicture();
            await convertToUrl();
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            child: Container(
                height: 200,
                width: 130,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                ),
                child: url == ''
                    ? const Center(
                        child: Icon(
                        Icons.add,
                        size: 48,
                        color: Colors.pink,
                      ))
                    : Image.network(url, fit: BoxFit.cover, loadingBuilder:
                        (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      })),
          ),
        ),
      ),
    );
  }
}
