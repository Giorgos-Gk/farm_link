import 'package:farm_link/config/Styles.dart';
import 'package:farm_link/config/Transitions.dart';
import 'package:farm_link/config/assets.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/pages/conversation_page_slide.dart';
import 'package:farm_link/widgets/circle_indicator.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int currentPage = 0;
  int age = 18;
  bool isKeyboardOpen = false;

  late PageController pageController;
  late AnimationController usernameFieldAnimationController;
  late Animation<double> profilePicHeightAnimation,
      usernameAnimation,
      ageAnimation;
  FocusNode usernameFocusNode = FocusNode();

  Alignment begin = Alignment.center;
  Alignment end = Alignment.bottomRight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
    usernameFieldAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    profilePicHeightAnimation = Tween<double>(begin: 100.0, end: 0.0)
        .animate(usernameFieldAnimationController)
      ..addListener(() => setState(() {}));

    usernameAnimation = Tween<double>(begin: 50.0, end: 10.0)
        .animate(usernameFieldAnimationController)
      ..addListener(() => setState(() {}));

    ageAnimation = Tween<double>(begin: 80.0, end: 10.0)
        .animate(usernameFieldAnimationController)
      ..addListener(() => setState(() {}));

    usernameFocusNode.addListener(() {
      if (usernameFocusNode.hasFocus) {
        usernameFieldAnimationController.forward();
      } else {
        usernameFieldAnimationController.reverse();
      }
    });

    pageController.addListener(() {
      setState(() {
        begin = Alignment(pageController.page ?? 0, pageController.page ?? 0);
        end = Alignment(
            1 - (pageController.page ?? 0), 1 - (pageController.page ?? 0));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: [Palette.gradientStartColor, Palette.gradientEndColor],
              ),
            ),
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: updatePageState,
                  children: [
                    buildPageOne(),
                    buildPageTwo(),
                  ],
                ),
                Positioned(
                  bottom: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      2,
                      (index) => CircleIndicator(index == currentPage),
                    ),
                  ),
                ),
                if (currentPage == 1)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: navigateToHome,
                      backgroundColor: Palette.primaryColor,
                      child: const Icon(Icons.done, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPageOne() {
    return Column(
      children: [
        const SizedBox(height: 250),
        Image.asset(Assets.appIcon, height: 100),
        const SizedBox(height: 30),
        Text(
          'Καλώς ήρθατε στο Farm Link',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 100),
        TextButton.icon(
          onPressed: () {
            pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            updatePageState(1);
          },
          icon: Image.asset(Assets.googleButton, height: 25),
          label: Text(
            'Συνεχίστε με Google',
            style: TextStyle(
              color: Palette.primaryTextColorLight,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPageTwo() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: profilePicHeightAnimation.value),
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage(Assets.user),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.camera, color: Colors.white, size: 15),
                Text(
                  'Set Profile Picture',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: usernameAnimation.value),
          Text('Εισάγετε την αγροτική σας ειδικότητα:',
              style: Styles.questionLight),
          const SizedBox(height: 20),
          Container(
            width: 120,
            child: TextField(
              focusNode: usernameFocusNode,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Ειδικότητα',
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Palette.primaryColor, width: 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updatePageState(int index) {
    setState(() {
      currentPage = index;
    });
  }

  Future<bool> onWillPop() async {
    if (currentPage == 1) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return false;
    }
    return true;
  }

  void navigateToHome() {
    Navigator.push(context, SlideLeftRoute(page: ConversationPageSlide()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    usernameFieldAnimationController.dispose();
    usernameFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final value = MediaQuery.of(context).viewInsets.bottom;
    final isVisible = value > 0;
    if (isKeyboardOpen != isVisible) {
      isKeyboardOpen = isVisible;
      if (!isVisible) {
        usernameFieldAnimationController.reverse();
      }
    }
  }
}
