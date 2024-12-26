import 'package:flutter/material.dart';
import 'package:farm_link/config/pallete.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController textEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Palette.primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: 'Γράψτε εδω...',
                  hintStyle: TextStyle(color: Palette.greyColor),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ),
            ),
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => {},
                color: Palette.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: Palette.greyColor, width: 0.5)),
          color: Colors.white),
    );
  }
}
