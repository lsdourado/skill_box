import 'package:flutter/material.dart';
import 'package:skill_box/src/screens/add_project_screen.dart';
import 'package:skill_box/src/tabs/feed_tab.dart';
import 'package:skill_box/src/tabs/my_projects_tab.dart';
import 'package:skill_box/src/tabs/profile_tab.dart';
import 'package:skill_box/src/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            centerTitle: true,
          ),
          body: FeedTab(),
          drawer: CustomDrawer(_pageController),
        ),
        Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=>AddProjectScreen())
              );
            },
          ),
          appBar: AppBar(
            title: Text("Meus projetos"),
            centerTitle: true,
          ),
          body: MyProjectsTab(),
          drawer: CustomDrawer(_pageController),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Perfil de usuário"),
            centerTitle: true,
          ),
          body: ProfileTab(),
          drawer: CustomDrawer(_pageController),
        ),
      ],
    );
  }
}