import 'package:flutter/material.dart';

import './account_screen.dart';
import './chat_screen.dart';
import './like_screen.dart';
import 'card_stack.dart';

/*
Title:HomePageScreen
Purpose:HomePageScreen
Created By:Chinmay Rele
*/

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int pageIndex = 0;
  final screens = [
    const CardsStackWidget(),
    const LikesScreen(),
    const ChatScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(children: screens, index: pageIndex),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            backgroundColor: Colors.white12,
            indicatorColor: Colors.transparent,
            labelTextStyle: MaterialStateProperty.all(
                const TextStyle(color: Colors.transparent))),
        child: NavigationBar(
          height: 70,
          selectedIndex: pageIndex,
          onDestinationSelected: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                size: 34,
                color: pageIndex == 0 ? Colors.redAccent : Colors.grey,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.favorite,
                size: 32,
                color: pageIndex == 1 ? Colors.amber : Colors.grey,
              ),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.message,
                size: 32,
                color: pageIndex == 2 ? Colors.indigo : Colors.grey,
              ),
              label: 'Message',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_pin,
                size: 32,
                color: pageIndex == 3 ? Colors.orange : Colors.grey,
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
