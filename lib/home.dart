// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Views/profile_page.dart';
import 'Views/dashboard.dart';
import 'Views/search.dart';

class Home extends StatefulWidget {
  final User user;
  // ignore: use_key_in_widget_constructors
  const Home({required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  // pages that are called
  final List<Widget> tabs = [
    Dashboard(FirebaseAuth.instance.currentUser!),
    Search(FirebaseAuth.instance.currentUser!),
    ProfilePage(FirebaseAuth.instance.currentUser!)
  ];

  // bottom nav bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: Colors.blue,
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            backgroundColor: Colors.blue,
            label: "SEARCH",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: Colors.blue,
            label: "PROFILE",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
