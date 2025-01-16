import 'package:farm_link/bloc/chat/chat_bloc.dart';
import 'package:farm_link/bloc/chat/chat_event.dart';
import 'package:farm_link/bloc/chat/chat_state.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/contact.dart';
import 'package:farm_link/pages/conversation_bottom.dart';
import 'package:farm_link/pages/conversation_page.dart';
import 'package:farm_link/widgets/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rubber/rubber.dart';

class ConversationPageSlide extends StatefulWidget {
  final Contact startContact;

  const ConversationPageSlide({Key? key, required this.startContact})
      : super(key: key);

  @override
  _ConversationPageSlideState createState() =>
      _ConversationPageSlideState(startContact);
}

class _ConversationPageSlideState extends State<ConversationPageSlide>
    with SingleTickerProviderStateMixin {
  late final RubberAnimationController controller;
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Contact startContact;
  late final ChatBloc chatBloc;
  List<Chat> chatList = [];
  bool isFirstLaunch = true;

  _ConversationPageSlideState(this.startContact);

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(FetchChatListEvent());
    controller = RubberAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is FetchedChatListState) {
                  chatList = state.chatList;
                  if (isFirstLaunch && chatList.isNotEmpty) {
                    isFirstLaunch = false;
                    final index = chatList.indexWhere(
                        (chat) => chat.username == startContact.username);
                    if (index != -1) {
                      chatBloc.add(PageChangedEvent(index, chatList[index]));
                      pageController.jumpToPage(index);
                    }
                  }
                }
              },
              child: Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return PageView.builder(
                      controller: pageController,
                      itemCount: chatList.length,
                      onPageChanged: (index) {
                        chatBloc.add(PageChangedEvent(index, chatList[index]));
                      },
                      itemBuilder: (context, index) {
                        return ConversationPage(chatList[index]);
                      },
                    );
                  },
                ),
              ),
            ),
            GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dy < 0) {
                  _scaffoldKey.currentState?.showBottomSheet(
                    (context) => const ConversationBottom(),
                  );
                }
              },
              child: InputWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
