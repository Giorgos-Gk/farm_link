import 'package:farm_link/bloc/chat/chat_bloc.dart';
import 'package:farm_link/bloc/chat/chat_state.dart';
import 'package:farm_link/config/assets.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/config/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height = 100;

  @override
  _ChatAppBarState createState() => _ChatAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ChatAppBarState extends State<ChatAppBar> {
  String username = "";
  Image image = Image.asset(Assets.user);
  late ChatBloc chatBloc;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      bloc: chatBloc,
      listener: (context, state) {
        if (state is FetchedContactDetailsState) {
          setState(() {
            username = state.user.username;
            image = (state.user.photoUrl.isNotEmpty)
                ? Image.network(
                    state.user.photoUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(Assets.user);
                    },
                  )
                : Image.asset(Assets.user);
          });
        }
      },
      child: Material(
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 2.0,
                spreadRadius: 0.1,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            color: Palette.primaryBackgroundColor,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          flex: 7,
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.attach_file,
                                        color: Palette.secondaryColor,
                                      ),
                                      onPressed: () => {},
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          username,
                                          style: Styles.textHeading,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Second row containing buttons for media
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 5, 5, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Φωτογραφίες',
                                  style: Styles.text,
                                ),
                                VerticalDivider(
                                  width: 30,
                                  color: Palette.primaryTextColor,
                                ),
                                Text(
                                  'Βίντεο',
                                  style: Styles.text,
                                ),
                                VerticalDivider(
                                  width: 30,
                                  color: Palette.primaryTextColor,
                                ),
                                Text('Αρχεία', style: Styles.text),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Display picture
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: image.image,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
