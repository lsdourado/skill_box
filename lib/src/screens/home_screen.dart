import 'package:flutter/material.dart';
import 'package:skill_box/src/tabs/feed_tab.dart';
import 'package:skill_box/src/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("Perfil de usuário"),
            centerTitle: true,
          ),
          body: ProfileTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            centerTitle: true,
          ),
          body: FeedTab(),
        ),
      ],
    );
  }
}