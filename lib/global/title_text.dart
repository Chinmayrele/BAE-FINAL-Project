import 'package:flutter/material.dart';

titleText(String text, bool isRequired) {
    return Container(
      margin: const EdgeInsets.only(left: 25, bottom: 8, top: 15),
      child: RichText(
          text: TextSpan(
              text: text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              children: [
            if (isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ])),
    );
  }