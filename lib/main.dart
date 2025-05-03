import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:farm_link/pages/login_page.dart';
import 'package:farm_link/pages/home_page.dart';
import 'package:farm_link/pages/registration_page.dart';
import 'package:farm_link/pages/conversation_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:farm_link/services/navigation_service.dart';
import 'package:timeago/timeago.dart' as timeago;

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

void _handleMessageNavigation(RemoteMessage message) {
  final data = message.data;
  final convID = data['conversationID'];
  final senderID = data['senderID'];
  final senderName = message.notification?.title ?? 'Chat';
  NavigationService.instance.navigateToRoute(
    MaterialPageRoute(
      builder: (_) => ConversationPage(
        conversationID: convID,
        receiverID: senderID,
        receiverName: senderName,
        receiverImage: '',
      ),
    ),
  );
}

Future<void> _setupNotifications() async {
  await FirebaseMessaging.instance.requestPermission();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _localNotifications.initialize(
    const InitializationSettings(android: androidSettings),
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
    final notif = msg.notification;
    if (notif != null) {
      _localNotifications.show(
        notif.hashCode,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'chat_channel',
            'Chat Messages',
            channelDescription: 'Ειδοποιήσεις νέων μηνυμάτων',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  timeago.setLocaleMessages('el', timeago.GrMessages());
  timeago.setDefaultLocale('el');
  await _setupNotifications();
  runApp(const FarmLink());
}

class FarmLink extends StatefulWidget {
  const FarmLink({Key? key}) : super(key: key);

  @override
  State<FarmLink> createState() => _FarmLinkState();
}

class _FarmLinkState extends State<FarmLink> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageNavigation(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Link',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 20, 179, 86),
        scaffoldBackgroundColor: const Color(0xFF1C1B1B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2A75BC),
          secondary: Color(0xFF2A75BC),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return HomePage();
          }
          return LoginPage();
        },
      ),
      routes: {
        'login': (_) => LoginPage(),
        'register': (_) => BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(),
              child: RegistrationPage(),
            ),
        'home': (_) => HomePage(),
      },
    );
  }
}
