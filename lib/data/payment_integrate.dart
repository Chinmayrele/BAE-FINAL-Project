import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/user_info.dart';
import '../providers/info_provider.dart';

class PaymentIntegrate extends StatefulWidget {
  const PaymentIntegrate({Key? key}) : super(key: key);

  @override
  State<PaymentIntegrate> createState() => _PaymentIntegrateState();
}

class _PaymentIntegrateState extends State<PaymentIntegrate> {
  TextEditingController amountController = TextEditingController(text: '79');
  late Razorpay _razorpay;
  late InfoProviders result;
  late UserInfos userProfiledata;
  bool isLoading = true;
  snackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    result = Provider.of<InfoProviders>(context, listen: false);
    result.fetchUSerProfileData().then((_) {
      userProfiledata = result.userInfo[0];
      setState(() {
        isLoading = false;
      });
    });
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    await FirebaseFirestore.instance
        .collection('profile')
        .doc(userProfiledata.userId)
        .update({
      "isSubscribed": true,
    });
    
    setState(() {});
    Navigator.of(context).pop();
    snackBar('Payement Succesfully done!!!');
    //debugPrint(
    //"RESPONSE ORDERID: ${response.orderId}\nPAYMENT ID ${response.paymentId}\nSIGNATURE ${response.signature}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    snackBar(response.message.toString());
    //debugPrint("CODE: ${response.code}\nMESSAGE ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    //debugPrint("WALLET NAME ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 60),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        )),
                    const SizedBox(width: 20),
                    const Text(
                      'Payment Gateway',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  height: size.height * 0.8,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withOpacity(0.4),
                          Colors.indigo.withOpacity(0.6)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                  child: Column(
                    children: [
                      Center(
                        child: RichText(
                          text: const TextSpan(
                              text: '𝓖𝓸 ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                    text: '𝓟𝓻𝓮𝓶𝓲𝓾𝓶!',
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold))
                              ]),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: const EdgeInsets.only(left: 15, right: 15),
                        child: TextField(
                          // focusNode: _focusNode,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          controller: amountController,
                          decoration: InputDecoration(
                            fillColor: Colors.white24,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.pink,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.pink,
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            prefixIcon: const Icon(
                              Icons.currency_rupee_sharp,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      buildRowText('Get Every Access to our app', size),
                      buildRowText(
                          'Start a conversation with your Match', size),
                      buildRowText('See who liked you', size),
                      buildRowText(
                          'Find your perfect match faster with premium', size),
                      const Spacer(),
                      Container(
                        height: 70,
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 30),
                        child: ElevatedButton(
                          onPressed: () {
                            launchPayment();
                          },
                          child: const Text(
                            'Make Payment',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.all(25),
                              primary: Colors.pink),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  launchPayment() {
    int amountToPay = int.parse(amountController.text) * 100;
    var options = {
      'key': 'rzp_test_KuLoLYlScCzm2t',
      'amount': '$amountToPay',
      'name': 'GAUTHAM RAJ',
      'description': 'Premium Member for App',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '7338714037', 'email': 'gauraj390@gmail.com'},
      // "external": {
      //   "wallets": ["paytm"]
      // },
    };
    try {
      _razorpay.open(options);
    } catch (err) {
      //debugPrint(err.toString());
    }
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
