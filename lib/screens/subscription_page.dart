import 'package:flutter/material.dart';

import '../data/payment_integrate.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      width: size.width * 0.87,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(15),
        // gradient: LinearGradient(
        //   colors: [
        //     Colors.indigo.withOpacity(0.4),
        //     Colors.indigo.withOpacity(0.6)
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          RichText(
              text: const TextSpan(
                  text: 'Buy ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                  children: [
                TextSpan(
                    text: 'Premium',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ))
              ])),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
                text: '\$1',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: '/month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size.width * 0.75,
            child: const Text(
              'Get Preminum to find your other part!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 25),
          buildRowText('Get every access to our app', size),
          buildRowText('Start a conversation with your match', size),
          buildRowText('See who liked you', size),
          buildRowText('Find your perfect match faster with premium', size),
          const Spacer(),
          Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const PaymentIntegrate()));
              },
              child: const Text(
                'Go Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          )
        ],
      ),
    );
  }

  buildRowText(String text, Size size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 10, left: 15),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.black,
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: size.width * 0.7,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
