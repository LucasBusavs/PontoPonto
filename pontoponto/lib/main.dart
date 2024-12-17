import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'NotesPage.dart';
import 'models/user_model.dart';
import 'Calendario.dart';
import 'Loading.dart';
import 'Login.dart';
import 'Cadastro.dart';
import 'Home.dart';
import 'Menu.dart';
import 'AccessScreen.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyDX1hazEf1Bjg8iZ_iKtRYOJNbUl_U75pk",
  authDomain: "pontoponto-79f6e.firebaseapp.com",
  projectId: "pontoponto-79f6e",
  storageBucket: "pontoponto-79f6e.appspot.com",
  messagingSenderId: "950052451127",
  appId: "1:950052451127:web:9fc8a76ffa714cc01ce0b2",
  measurementId: "G-R3B4017770",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: firebaseConfig);
    }
  } catch (e) {
    debugPrint('Erro ao inicializar o Firebase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingWidget(),
        '/login': (context) => LoginWidget(),
        '/cadastro': (context) => CadastroWidget(),
        '/menu': (context) => MenuWidget(),
        '/notes': (context) => NotesPage(),
        '/calendario': (context) {
          final String? userId = Provider.of<UserModel>(context).userId;
          if (userId == null) {
            return LoginWidget();
          } else {
            return CalenWidget(userId: userId);
          }
        },
        '/home': (context) {
          final String? userId = Provider.of<UserModel>(context).userId;
          final String? userEmail = FirebaseAuth.instance.currentUser?.email;

          if (userEmail == null || userId == null) {
            return LoginWidget();
          } else {
            return HomeWidget(email: userEmail, userId: userId);
          }
        },
        '/access': (context) => AccessScreen(),
      },
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? onDetached;

  LifecycleEventHandler({this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onDetached?.call();
    }
  }
}