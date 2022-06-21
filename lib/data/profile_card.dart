import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../common/color_constants.dart';
import '../global/show_modal_sheet.dart';
import '../models/que_ans_info.dart';
import '../models/user_info.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard(
      {Key? key,
      required this.profile,
      required this.queAnsDataResult,
      required this.index})
      : super(key: key);
  final UserInfos profile;
  final QueAnsInfo queAnsDataResult;
  final int index;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  // late InfoProviders result;
  // late QueAnsInfo queAnsDataResult;
  // bool isLoadingQueAns = true;
  // @override
  // void initState() {
  //   result = Provider.of<InfoProviders>(context, listen: false);
  //   result.fetchQueAnsData(widget.profile.userId).then((value) {
  //     queAnsDataResult = value;
  //     setState(() {
  //       isLoadingQueAns = false;
  //     });
  //   });
  //   super.initState();
  // }

  @override
  void dispose() {
    // queAnsDataResult;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      width: size.width * 0.87,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.pink.withOpacity(0.8),
              blurRadius: 6,
              spreadRadius: 3),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: widget.index == 0
                  ? const SizedBox()
                  : ClipRRect(
                      // borderRadius: BorderRadius.circular(70),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.pink),
                            ),
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
                        imageUrl: widget.profile.imageUrls[0],
                        width: 180.0,
                        height: 180.0,
                        fit: BoxFit.cover,
                      ),
                    ),
              // Image.network(
              //     widget.profile.imageUrls[0],
              //     fit: BoxFit.cover,
              //     //   loadingBuilder:
              //     //       (BuildContext context, Widget child,
              //     //           ImageChunkEvent? loadingProgress) {
              //     // if (loadingProgress == null) return child;
              //     // return Center(
              //     //   child: CircularProgressIndicator(
              //     //     color: Colors.white,
              //     //     value: loadingProgress.expectedTotalBytes != null
              //     //         ? loadingProgress.cumulativeBytesLoaded /
              //     //             loadingProgress.expectedTotalBytes!
              //     //         : null,
              //     //   ),
              //     // );
              //   ),
            ),
            widget.index == 0
                ? Positioned(
                    left: size.width * 0.07,
                    top: size.height * 0.35,
                    child: const Text(
                      'Looks like you have seen everyone for now!!!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    width: size.width * 0.75,
                  )
                : const SizedBox(),
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                ColorConstants.kBlack.withOpacity(0.25),
                ColorConstants.kBlack.withOpacity(0),
              ], end: Alignment.topCenter, begin: Alignment.bottomCenter)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.55),
                            Colors.red.withOpacity(0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: size.width * 0.72,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.index == 0
                                          ? ''
                                          : widget.profile.name,
                                      style: const TextStyle(
                                          color: ColorConstants.kWhite,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      widget.index == 0
                                          ? ''
                                          : widget.profile.age.toString(),
                                      style: const TextStyle(
                                        color: ColorConstants.kWhite,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    widget.index == 0
                                        ? SizedBox()
                                        : Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: ColorConstants.kGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.index == 0
                                          ? ''
                                          : "Recently Active",
                                      style: const TextStyle(
                                        color: ColorConstants.kWhite,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                          widget.index == 0
                              ? const SizedBox()
                              : Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showsheet(
                                          context,
                                          size,
                                          widget.queAnsDataResult,
                                          widget.profile);
                                    },
                                    child: SizedBox(
                                      width: size.width * 0.2,
                                      child: const Center(
                                        child: Icon(
                                          Icons.info,
                                          color: ColorConstants.kWhite,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
