import 'package:farm_link/bloc/contacts/contacts_bloc.dart';
import 'package:farm_link/bloc/contacts/contacts_event.dart';
import 'package:farm_link/bloc/contacts/contacts_state.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/models/contact.dart';
import 'package:farm_link/repository/user_data_repository.dart';
import 'package:farm_link/widgets/contact_row_widget.dart';
import 'package:farm_link/widgets/gradient_fab.dart';
import 'package:farm_link/widgets/quick_scroll_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/assets.dart';
import '../config/decorations.dart';
import '../config/styles.dart';

class ContactListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactListPageState();

  const ContactListPage();
}

class _ContactListPageState extends State<ContactListPage>
    with TickerProviderStateMixin {
  late ContactsBloc contactsBloc;
  late UserDataRepository userDataRepository;
  late ScrollController scrollController;
  final TextEditingController usernameController = TextEditingController();
  List<Contact> contacts = [];
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    userDataRepository = UserDataRepository();
    contactsBloc = ContactsBloc(userDataRepository: userDataRepository);
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    );
    animationController.forward();
    contactsBloc.add(FetchContactsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Palette.primaryBackgroundColor,
        body: BlocProvider(
          create: (context) => contactsBloc,
          child: BlocListener<ContactsBloc, ContactsState>(
            listener: (context, state) {
              if (state is AddContactsSuccessState) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Η επαφή καταχωρήθηκε!"),
                  ),
                );
              } else if (state is ErrorState ||
                  state is AddContactsFailedState) {
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
                    SliverAppBar(
                      backgroundColor: Palette.primaryBackgroundColor,
                      expandedHeight: 180.0,
                      pinned: true,
                      elevation: 0,
                      centerTitle: true,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text("Επαφές", style: Styles.appBarTitle),
                      ),
                    ),
                    BlocBuilder<ContactsBloc, ContactsState>(
                      builder: (context, state) {
                        if (state is FetchingContactsState) {
                          return SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }
                        if (state is FetchedContactsState) {
                          contacts = state.contacts;
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ContactRowWidget(contact: contacts[index]);
                            },
                            childCount: contacts.length,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 190),
                  child: QuickScrollBar(
                    nameList: contacts.map((c) => c.name).toList(),
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: GradientFab(
          child: const Icon(Icons.add),
          animation: animation,
          onPressed: () => showAddContactsBottomSheet(context),
          elevation: 0,
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

  void showAddContactsBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return BlocProvider.value(
          value: contactsBloc,
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
                  Image.asset(Assets.social),
                  const SizedBox(height: 20),
                  Text('Προσθεση Επικοινωνίας', style: Styles.textHeading),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    textAlign: TextAlign.center,
                    style: Styles.subHeading,
                    decoration: Decorations.getInputDecoration(
                      hint: 'Ειδικότητα',
                      isPrimary: true,
                      context: parentContext,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GradientFab(
                      child: const Icon(Icons.done),
                      animation: animation,
                      elevation: 0.0,
                      onPressed: () {
                        contactsBloc.add(
                          AddContactsEvent(username: usernameController.text),
                        );
                      },
                    ),
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
