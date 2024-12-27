import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/config/styles.dart';
import 'package:farm_link/widgets/gradient_fab.dart';
import 'package:farm_link/widgets/quick_scroll_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage>
    with TickerProviderStateMixin {
  late final ScrollController scrollController;

  // Μπορείς να αλλάξεις τη λίστα σε List<String> για μεγαλύτερη αυστηρότητα
  final List<String> nameList = [
    'Anya Ostrem',
    'Burt Hutchison',
    'Chana Sobolik',
    'Chasity Nutt',
    'Deana Tenenbaum',
    'Denae Cornelius',
    'Elisabeth Saner',
    'Eloise Rocca',
    'Eloy Kallas',
    'Esther Hobby',
    'Euna Sulser',
    'Florinda Convery',
    'Franklin Nottage',
    'Gale Nordeen',
    'Garth Vanderlinden',
    'Gracie Schulte',
    'Inocencia Eaglin',
    'Jillian Germano',
    'Jimmy Friddle',
    'Juliann Bigley',
    'Kia Gallaway',
    'Larhonda Ariza',
    'Larissa Reichel',
    'Lavone Beltz',
    'Lazaro Bauder',
    'Len Northup',
    'Leonora Castiglione',
    'Lynell Hanna',
    'Madonna Heisey',
    'Marcie Borel',
    'Margit Krupp',
    'Marvin Papineau',
    'Mckinley Yocom',
    'Melita Briones',
    'Moses Strassburg',
    'Nena Recalde',
    'Norbert Modlin',
    'Onita Sobotka',
    'Raven Ecklund',
    'Robert Waldow',
    'Roxy Lovelace',
    'Rufina Chamness',
    'Saturnina Hux',
    'Shelli Perine',
    'Sherryl Routt',
    'Soila Phegley',
    'Tamera Strelow',
    'Tammy Beringer',
    'Vesta Kidd',
    'Yan Welling'
  ];

  late final AnimationController animationController;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()..addListener(scrollListener);

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Δημιουργούμε ένα βασικό CurvedAnimation
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    );

    // Ξεκινάμε το FAB εμφανές
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
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
                    title: Text(
                      "Contacts",
                      style: Styles.appBarTitle,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Δείγμα widget για το row της επαφής
                      return ContactRowWidget(name: nameList[index]);
                    },
                    childCount: nameList.length,
                  ),
                ),
              ],
            ),

            // Το QuickScrollBar (αν θες το γρήγορο scroll στα δεξιά)
            Container(
              margin: const EdgeInsets.only(top: 190),
              child: QuickScrollBar(
                nameList: nameList,
                scrollController: scrollController,
              ),
            ),
          ],
        ),

        // FAB που χρησιμοποιεί μόνο ScaleTransition (χωρίς AnimatedSize)
        floatingActionButton: GradientFab(
          animation: animation,
          // Δεν περνάμε vsync, γιατί το αφαιρέσαμε από το GradientFab
        ),
      ),
    );
  }

  // Όταν κάνουμε scroll, αν η φορά είναι forward (προς τα κάτω), εμφανίζουμε το FAB
  // Διαφορετικά, το κρύβουμε
  void scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }
}

// Δείγμα εμφάνισης μιας γραμμής επαφής
class ContactRowWidget extends StatelessWidget {
  final String name;

  const ContactRowWidget({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
    );
  }
}
