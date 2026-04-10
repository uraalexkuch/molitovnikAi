import 'package:flutter/material.dart';
import 'package:molitovnik/pages/Data/widgets/about.dart';
import 'package:molitovnik/pages/Play/manage_playlist.dart';

import 'package:sz_fancy_bottom_navigation/sz_fancy_bottom_navigation.dart';
import 'categories_screen.dart';


class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  GlobalKey bottomNavigationKey = GlobalKey();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return  SafeArea(
            left: true,
            top: true,
            right: true,
            bottom: true,
            child:Scaffold(
     body:Center(
        child:
        NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.3,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 20,
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          "МОЛИТОВНИК ВОЇНА",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Church",
                            fontSize: 18.0,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    background: Image.asset(
                      "images/santgeorg.jpg",
                     fit: BoxFit.fill,
                    )),
              ),
            ];
          },
          body: (
              PageView(
                controller: _pageController,
                children: <Widget>[
                  _getPage(0),
                  _getPage(1),
                  _getPage(2),
                ],

              )
          ),
        ),
     ),
      bottomNavigationBar: FancyBottomNavigation(
          pageController: _pageController,
          tabs: [
            TabData(
                iconData: Icons.library_books,
                title: "Текст",
                onclick: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CategoriesScreen()))),
            TabData(
                iconData: Icons.multitrack_audio,
                title: "Аудіо",
                onclick: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ManagePlaylist()))),
            TabData(
                iconData: Icons.home,
                title: "Про затсосунок",
                onclick: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const About()))),
          ],
          initialSelection: 0,
          key: bottomNavigationKey,

          barBackgroundColor: Colors.amberAccent,

      ),
    )
        );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return const CategoriesScreen();
      case 1:
        return const ManagePlaylist();
      case 2:
        return const About();
      default:
        return const CategoriesScreen();
    }
  }
}
