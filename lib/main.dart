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

const AndroidNotificationChannel _chatChannel = AndroidNotificationChannel(
  'chat_channel',
  'Chat Messages',
  description: 'Ειδοποιήσεις νέων μηνυμάτων',
  importance: Importance.high,
);

@pragma('vm:entry-point') // απαιτείται στο background isolate
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  // Εξασφάλισε ότι το plugin έχει γίνει initialize στο background isolate
  final plugin = FlutterLocalNotificationsPlugin();
  const init = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await plugin.initialize(init);

  final title = msg.notification?.title ?? msg.data['title'];
  final body = msg.notification?.body ?? msg.data['body'];
  final payload = msg.data['conversationID'] ?? '';

  if (title != null || body != null) {
    await plugin.show(
      msg.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chatChannel.id,
          _chatChannel.name,
          channelDescription: _chatChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}

Future<void> _setupNotifications() async {
  await FirebaseMessaging.instance.requestPermission();

  await _localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (resp) {
      final convID = resp.payload;
      if (convID != null && convID.isNotEmpty) {
        NavigationService.instance.navigateToRoute(
          MaterialPageRoute(
            builder: (_) => ConversationPage(
              conversationID: convID,
              receiverID: '',
              receiverName: 'Chat',
              receiverImage: '',
            ),
          ),
        );
      }
    },
  );

  // 3) Δημιουργία καναλιού (Android 8+)
  final androidPlugin =
      _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(_chatChannel);

  // 4) iOS: εμφάνιση και στο foreground
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(alert: true, badge: true);
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
