import 'package:farm_link/bloc/contacts/contacts_bloc.dart';
import 'package:farm_link/bloc/contacts/contacts_event.dart';
import 'package:farm_link/bloc/contacts/contacts_state.dart';
import 'package:farm_link/config/assets.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/config/styles.dart';
import 'package:farm_link/models/contact.dart';
import 'package:farm_link/widgets/contact_row_widget.dart';
import 'package:farm_link/widgets/gradient_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage>
    with TickerProviderStateMixin {
  late final ContactsBloc contactsBloc;
  final ScrollController scrollController = ScrollController();
  final TextEditingController usernameController = TextEditingController();
  late final AnimationController animationController;
  late final Animation<double> animation;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    contactsBloc = BlocProvider.of<ContactsBloc>(context);
    scrollController.addListener(scrollListener);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.linear);
    animationController.forward();
    contactsBloc.add(FetchContactsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Palette.primaryBackgroundColor,
        appBar: AppBar(
          backgroundColor: Palette.primaryBackgroundColor,
          centerTitle: true,
          elevation: 10,
          title: Text("Επαφές", style: Styles.appBarTitle),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'Logout') {
                  // Add logout logic
                } else if (value == 'Settings') {
                  // Navigate to settings
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Settings', 'Logout'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: BlocListener<ContactsBloc, ContactsState>(
          listener: (context, state) {
            if (state is AddContactSuccessState) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("Η επαφή προστεθηκε"),
                ),
              );
            } else if (state is ErrorState || state is AddContactFailedState) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(state.exception.errorMessage()),
                ),
              );
            }
          },
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  BlocBuilder<ContactsBloc, ContactsState>(
                    builder: (context, state) {
                      if (state is FetchingContactsState) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (state is FetchedContactsState) {
                        contacts = state.contacts;
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ContactRowWidget(
                              contact: contacts[index],
                            );
                          },
                          childCount: contacts.length,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: GradientFab(
          animation: animation,
          onPressed: () => showAddContactsBottomSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  void showAddContactsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: const Color(0xFF737373),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset(Assets.social),
                  ),
                  const SizedBox(height: 40),
                  Text('Προσθεστε μια επαφή', style: Styles.textHeading),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    child: TextField(
                      controller: usernameController,
                      textAlign: TextAlign.center,
                      style: Styles.subHeading,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GradientFab(
                        elevation: 0.0,
                        child: Icon(Icons.done, color: Palette.primaryColor),
                        onPressed: () {
                          contactsBloc.add(AddContactEvent(
                              username: usernameController.text));
                        },
                        animation: animation,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}
