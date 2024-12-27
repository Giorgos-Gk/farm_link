import 'package:flutter/material.dart';
import '../config/pallete.dart';

class QuickScrollBar extends StatefulWidget {
  final List<String> nameList;
  final ScrollController scrollController;

  const QuickScrollBar({
    Key? key,
    required this.nameList,
    required this.scrollController,
  }) : super(key: key);

  @override
  _QuickScrollBarState createState() =>
      _QuickScrollBarState(nameList, scrollController);
}

class _QuickScrollBarState extends State<QuickScrollBar> {
  double offsetContainer = 0.0;
  String? scrollBarText;
  String? scrollBarTextPrev;
  double? scrollBarHeight;
  final double contactRowSize = 45.0;
  final double scrollBarMarginRight = 50.0;
  double? scrollBarContainerHeight;
  int scrollBarPosSelected = 0;
  double scrollBarHeightDiff = 0.0;
  double screenHeight = 0.0;
  final ScrollController scrollController;
  bool scrollBarBubbleVisibility = false;
  final List<String> nameList;

  _QuickScrollBarState(this.nameList, this.scrollController);

  final List<String> alphabetList = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      scrollBarBubbleVisibility = true;
      if (scrollBarHeight == null || scrollBarContainerHeight == null) return;

      final newOffset = offsetContainer + details.delta.dy;
      if (newOffset >= 0 &&
          newOffset <= (scrollBarContainerHeight! - scrollBarHeight!)) {
        offsetContainer = newOffset;

        scrollBarPosSelected =
            ((offsetContainer / scrollBarHeight!) % alphabetList.length)
                .round();

        scrollBarText = alphabetList[scrollBarPosSelected];

        if (scrollBarText != scrollBarTextPrev) {
          for (var i = 0; i < nameList.length; i++) {
            if (scrollBarText!
                    .compareTo(nameList[i].toUpperCase().substring(0, 1)) ==
                0) {
              scrollController.jumpTo(i * contactRowSize);
              break;
            }
          }
          scrollBarTextPrev = scrollBarText;
        }
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    offsetContainer = details.globalPosition.dy - scrollBarHeightDiff;
    setState(() {
      scrollBarBubbleVisibility = true;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      scrollBarBubbleVisibility = false;
    });
  }

  Widget _getBubble() {
    if (!scrollBarBubbleVisibility) {
      return Container();
    }
    return Container(
      decoration: BoxDecoration(
        color: Palette.accentColor,
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
      ),
      width: 30,
      height: 30,
      child: Center(
        child: Text(
          scrollBarText ?? alphabetList.first,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _getAlphabetItem(int index) {
    return Expanded(
      child: Container(
        width: 40,
        height: 20,
        alignment: Alignment.center,
        child: Text(
          alphabetList[index],
          style: (index == scrollBarPosSelected)
              ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)
              : const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        scrollBarHeightDiff = screenHeight - constraints.biggest.height;
        scrollBarHeight = constraints.biggest.height / alphabetList.length;
        scrollBarContainerHeight = constraints.biggest.height;

        return Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onVerticalDragEnd: _onVerticalDragEnd,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragStart: _onVerticalDragStart,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      alphabetList.length,
                      (index) => _getAlphabetItem(index),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: scrollBarMarginRight,
              top: offsetContainer,
              child: _getBubble(),
            ),
          ],
        );
      },
    );
  }
}
