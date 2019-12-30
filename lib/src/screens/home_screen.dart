import 'package:flutter/material.dart';
import 'package:skill_box/src/tabs/feed_tab.dart';
import 'package:skill_box/src/tabs/my_projects_tab.dart';
import 'package:skill_box/src/tabs/profile_tab.dart';
import 'package:skill_box/src/widgets/custom_drawer.dart';
import 'package:skill_box/src/widgets/notifications_icon.dart';

class HomeScreen extends StatelessWidget {

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        _buildPage(FeedTab(), "Home"),

        _buildPage(MyProjectsTab(), "Meus projetos"),

        _buildPage(ProfileTab(), "Perfil de usuário"),

      ],
    );
  }

  Widget _buildPage(Widget tab, String titulo){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          titulo,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          NotificationsIcon()
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: tab,
      drawer: CustomDrawer(_pageController),
    );
  }
}