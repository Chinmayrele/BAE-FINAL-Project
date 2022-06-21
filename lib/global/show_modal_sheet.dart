import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/que_ans_info.dart';
import '../models/user_info.dart';

showsheet(BuildContext ctx, Size size, QueAnsInfo queAnsDataResult,
    UserInfos userProfileDataResult) {
  showModalBottomSheet(
      context: ctx,
      builder: (ctx) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: size.width * 0.2,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(5)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                // controller: widget.controller,
                children: [
                  const SizedBox(height: 17),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.pink[300]!.withOpacity(0.4),
                                    Colors.pink[300]!.withOpacity(0.6)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight),
                              // color: Colors.pink[200],
                              borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.only(right: 15),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            // result
                            userProfileDataResult.about,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 17),
                          ),
                        ),
                        // const SizedBox(height: 15),
                        // EXTRA IMAGE NUMBER 1
                        userProfileDataResult.imageUrls.length > 1
                            ? Container(
                                height: size.height * 0.4,
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 20, top: 20),
                                child: Image.network(
                                    userProfileDataResult.imageUrls[1],
                                    fit: BoxFit.cover, loadingBuilder:
                                        (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                }),
                              )
                            : const SizedBox(height: 15),
                        const Text(
                          'My Basics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 15,
                          runSpacing: 8,
                          children: [
                            buildMyBasics(queAnsDataResult.vacationStatus),
                            buildMyBasics(queAnsDataResult.drinkStatus),
                            buildMyBasics(queAnsDataResult.exerciseStatus),
                            buildMyBasics(
                                queAnsDataResult.heightStatus + ' cm'),
                            buildMyBasics(queAnsDataResult.nightStatus),
                          ],
                        ),
                        // const SizedBox(height: 15),
                        // EXTRA IMAGE NUMBER 2
                        userProfileDataResult.imageUrls.length > 2
                            ? Container(
                                height: size.height * 0.35,
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 12, top: 15),
                                child: Image.network(
                                    userProfileDataResult.imageUrls[2],
                                    fit: BoxFit.cover, loadingBuilder:
                                        (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                }),
                              )
                            : const SizedBox(height: 15),

                        const Text('My Interests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 15,
                          runSpacing: 8,
                          children: [
                            buildMyBasics(userProfileDataResult.interest),
                          ],
                        ),
                        // IF IMAGE IS THERE
                        // const SizedBox(height: 15),
                        // EXTRA IMAGE NUMBER 3
                        userProfileDataResult.imageUrls.length > 3
                            ? Container(
                                height: size.height * 0.35,
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 12, top: 15),
                                child: Image.network(
                                    userProfileDataResult.imageUrls[3],
                                    fit: BoxFit.cover, loadingBuilder:
                                        (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                }),
                              )
                            : const SizedBox(height: 15),

                        Row(
                          children: [
                            Text(
                              '${userProfileDataResult.name.split(' ')[0]}\'s Location',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.location_on,
                              color: Color.fromARGB(255, 220, 87, 132),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        buildMyBasics(userProfileDataResult.address),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
      backgroundColor: Colors.black,
      constraints: BoxConstraints(minHeight: 0, maxHeight: size.height * 0.55));
}

buildMyBasics(String text) {
  return Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.pink.withOpacity(0.4), Colors.pink.withOpacity(0.65)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}
