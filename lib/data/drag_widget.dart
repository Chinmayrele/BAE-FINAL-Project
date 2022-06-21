import 'package:bae_dating_app/data/profile_card.dart';
import 'package:bae_dating_app/data/tag_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global/simple_container.dart';
import '../models/que_ans_info.dart';
import '../models/user_info.dart';
import '../providers/info_provider.dart';

enum Swipe { left, right, none }

// var indexRR = 0;

class DragWidget extends StatefulWidget {
  const DragWidget({
    Key? key,
    required this.profile,
    required this.index,
    required this.swipeNotifier,
    required this.iLike,
    required this.intersectionOfLikes,
    required this.isViewed,
    required this.whoLikedMe,
    required this.length,
  }) : super(key: key);
  final UserInfos profile;
  final int index;
  final ValueNotifier<Swipe> swipeNotifier;
  final List<dynamic> iLike;
  final List isViewed;
  final List whoLikedMe;
  final List intersectionOfLikes;
  final int length;

  @override
  State<DragWidget> createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);
  List whoLikedMeOther = [];
  late InfoProviders result;
  late QueAnsInfo queAnsDataResult;
  bool isLoadingQueAns = true;
  @override
  void initState() {
    if (widget.index != 0) {
      result = Provider.of<InfoProviders>(context, listen: false);
      result.fetchQueAnsData(widget.profile.userId).then((value) {
        queAnsDataResult = value;
        setState(() {
          isLoadingQueAns = false;
        });
      });
    }
    if (widget.index == 0) {
      setState(() {
        isLoadingQueAns = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // indexRR = widget.index;
    // final result = Provider.of<InfoProviders>(context,listen: false);
    // result.changeIndex(widget.index);
    //debugPrint('BUILD ENTERED IN DRAG WIDGET:>>>>>>>');
    return isLoadingQueAns
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
        // : widget.index == widget.length - 1
        //     ? SimpleContainer()
        : Center(
            child: Draggable<int>(
              // Data is the value this Draggable stores.
              data: widget.index,
              feedback: Material(
                color: Colors.transparent,
                child: ValueListenableBuilder(
                  valueListenable: swipeNotifier,
                  builder: (context, swipe, _) {
                    return RotationTransition(
                      turns: swipe != Swipe.none
                          ? swipe == Swipe.left
                              ? const AlwaysStoppedAnimation(-15 / 360)
                              : const AlwaysStoppedAnimation(15 / 360)
                          : const AlwaysStoppedAnimation(0),
                      child: Stack(
                        children: [
                          // widget.index == widget.length-1 ? QueAnsInfo(relationStatus: 'relationStatus', vacationStatus: 'vacationStatus', nightStatus: 'nightStatus', smokeStatus: 'smokeStatus', drinkStatus: 'drinkStatus', exerciseStatus: 'exerciseStatus', heightStatus: 'heightStatus') :
                          ProfileCard(
                            queAnsDataResult: widget.index == 0
                                ? QueAnsInfo(
                                    relationStatus: 'relationStatus',
                                    vacationStatus: 'vacationStatus',
                                    nightStatus: 'nightStatus',
                                    smokeStatus: 'smokeStatus',
                                    drinkStatus: 'drinkStatus',
                                    exerciseStatus: 'exerciseStatus',
                                    heightStatus: 'heightStatus',
                                  )
                                : queAnsDataResult,
                            profile: widget.profile,
                            index: widget.index,
                          ),
                          widget.index != 0
                              ? swipe != Swipe.none
                                  ? swipe == Swipe.right
                                      ? Positioned(
                                          top: 40,
                                          left: 20,
                                          child: Transform.rotate(
                                            angle: 12,
                                            child: TagWidget(
                                              text: 'LIKE',
                                              color: Colors.green[400]!,
                                            ),
                                          ),
                                        )
                                      : Positioned(
                                          top: 50,
                                          right: 24,
                                          child: Transform.rotate(
                                            angle: -12,
                                            child: TagWidget(
                                              text: 'DISLIKE',
                                              color: Colors.red[400]!,
                                            ),
                                          ),
                                        )
                                  : const SizedBox.shrink()
                              : SizedBox(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              onDragCompleted: () async {
                if (swipeNotifier.value == Swipe.right) {
                  widget.isViewed.add(widget.profile.userId);
                  widget.iLike.add(widget.profile.userId);
                  // //debugPrint("I LIKED LIST OBJECT BEFORE ASSIGNING: ${widget.iLike[0]}");
                  for (var i in widget.iLike) {
                    for (var j in widget.whoLikedMe) {
                      if (i == j) {
                        widget.intersectionOfLikes.add(i);
                      }
                    }
                  }
                  // widget.tempILiked = widget.iLiked;
                  // widget.tempILike.add(widget.profile.userId);
                  whoLikedMeOther.add(FirebaseAuth.instance.currentUser!.uid);
                  // widget.iLike
                  //     .removeWhere((element) => !widget.whoLikedMe.contains(element));
                  await FirebaseFirestore.instance
                      .collection('profile')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    "isViewed": widget.isViewed,
                    "iLike": widget.iLike,
                    "intersectionLikes": widget.intersectionOfLikes,
                  });
                  await FirebaseFirestore.instance
                      .collection('profile')
                      .doc(widget.profile.userId)
                      .update({
                    "whoLikedMe": whoLikedMeOther,
                  });
                }
                if (swipeNotifier.value == Swipe.left) {
                  widget.isViewed.add(widget.profile.userId);
                  await FirebaseFirestore.instance
                      .collection('profile')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    "isViewed": widget.isViewed,
                  });
                }
              },
              onDragUpdate: (DragUpdateDetails dragUpdateDetails) async {
                // When Draggable widget is dragged right
                if (dragUpdateDetails.delta.dx > 0 &&
                    dragUpdateDetails.globalPosition.dx >
                        MediaQuery.of(context).size.width / 2) {
                  swipeNotifier.value = Swipe.right;
                }
                // When Draggable widget is dragged left
                if (dragUpdateDetails.delta.dx < 0 &&
                    dragUpdateDetails.globalPosition.dx <
                        MediaQuery.of(context).size.width / 2) {
                  swipeNotifier.value = Swipe.left;
                }
              },
              childWhenDragging: Container(
                color: Colors.transparent,
              ),

              child: ProfileCard(
                queAnsDataResult: widget.index == 0
                    ? QueAnsInfo(
                        relationStatus: 'relationStatus',
                        vacationStatus: 'vacationStatus',
                        nightStatus: 'nightStatus',
                        smokeStatus: 'smokeStatus',
                        drinkStatus: 'drinkStatus',
                        exerciseStatus: 'exerciseStatus',
                        heightStatus: 'heightStatus',
                        )
                    : queAnsDataResult,
                profile: widget.profile,
                index: widget.index,
              ),
            ),
          );
  }
}
