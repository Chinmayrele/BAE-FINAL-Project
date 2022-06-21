import 'package:flutter/material.dart';

class SimpleContainer extends StatefulWidget {
  const SimpleContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<SimpleContainer> createState() => _SimpleContainerState();
}

class _SimpleContainerState extends State<SimpleContainer> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      width: size.width * 0.87,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Center(
            child: Text(
              'Looks like you have seen everyone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
