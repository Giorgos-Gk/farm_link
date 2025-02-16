import 'package:flutter/material.dart';

import './profile_page.dart';
import './recent_conversations_page.dart';
import './search_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Farm Link", style: TextStyle(color: Colors.green)),
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline, size: 25)),
            Tab(icon: Icon(Icons.chat_bubble_outline, size: 25)),
            Tab(icon: Icon(Icons.person_outline, size: 25)),
          ],
        ),
      ),
      body: _tabBarPages(_height, _width),
    );
  }

  Widget _tabBarPages(double height, double width) {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(height, width),
        RecentConversationsPage(height, width),
        ProfilePage(height, width),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
