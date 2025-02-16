import 'package:farm_link/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/db_service.dart';
import '../services/navigation_service.dart';
import '../pages/conversation_page.dart';
import '../models/contact.dart';

class SearchPage extends StatefulWidget {
  final double _height;
  final double _width;

  const SearchPage(this._height, this._width, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: _searchPageUI(),
    );
  }

  Widget _searchPageUI() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _userSearchField(),
            _usersListView(auth),
          ],
        );
      },
    );
  }

  Widget _userSearchField() {
    return SizedBox(
      height: widget._height * 0.08,
      width: widget._width,
      child: TextField(
        autocorrect: false,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (input) {
          setState(() {
            _searchText = input;
          });
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white),
          labelStyle: TextStyle(color: Colors.white),
          labelText: "Αναζητηση",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _usersListView(AuthProvider auth) {
    return StreamBuilder<List<Contact>>(
      stream: auth.user != null
          ? DBService.instance.getUsersInDB(_searchText)
          : null,
      builder: (context, snapshot) {
        var _usersData = snapshot.data ?? [];

        _usersData.removeWhere((_contact) => _contact.id == auth.user!.uid);

        return snapshot.hasData
            ? SizedBox(
                height: widget._height * 0.75,
                child: ListView.builder(
                  itemCount: _usersData.length,
                  itemBuilder: (context, index) {
                    var _userData = _usersData[index];
                    var _currentTime = DateTime.now();
                    var _recipientID = _userData.id;
                    var _isUserActive = !_userData.lastSeen.toDate().isBefore(
                          _currentTime.subtract(const Duration(hours: 1)),
                        );

                    return ListTile(
                      onTap: () {
                        DBService.instance.createOrGetConversation(
                          auth.user!.uid,
                          _recipientID,
                          (String conversationID) {
                            NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ConversationPage(
                                    conversationID: conversationID,
                                    receiverID: _recipientID,
                                    receiverName: _userData.name,
                                    receiverImage: _userData.image,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      title: Text(_userData.name),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _userData.image.isNotEmpty
                                ? NetworkImage(_userData.image)
                                : const AssetImage("assets/user.png")
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(_isUserActive ? "Ενεργός τώρα" : "Last Seen",
                              style: const TextStyle(fontSize: 15)),
                          _isUserActive
                              ? Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                )
                              : Text(
                                  timeago.format(_userData.lastSeen.toDate()),
                                  style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    );
                  },
                ),
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
