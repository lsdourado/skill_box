import 'package:flutter/material.dart';
import 'package:skill_box/src/tabs/feed_tab.dart';
import 'package:skill_box/src/tabs/my_projects_tab.dart';
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
      //physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        MyProjectsTab(),
        FeedTab(),
        ProfileTab(),
      ],
    );
  }
}