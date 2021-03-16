import 'package:flutter/material.dart';
import 'package:mazzle/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class HomePage extends StatefulWidget {
  final UserData userData;

  HomePage({@required this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  var _pages = [
    PageInventory(),
    PageMid(),
    PageMidEnd(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mazzle'),
        centerTitle: true,
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: '나의 종목'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '진행종목'),
          BottomNavigationBarItem(icon: Icon(Icons.portrait), label: '종료종목'),
        ],
      ),
    );
  }
}

// PageInventory
class PageInventory extends StatefulWidget {
  @override
  _PageInventoryState createState() => _PageInventoryState();
}

class _PageInventoryState extends State<PageInventory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('e'),
    );
  }
}

// PageMid
class PageMid extends StatefulWidget {
  @override
  _PageMidState createState() => _PageMidState();
}

class _PageMidState extends State<PageMid> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// PageMidEnd
class PageMidEnd extends StatefulWidget {
  @override
  _PageMidEndState createState() => _PageMidEndState();
}

class _PageMidEndState extends State<PageMidEnd> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


