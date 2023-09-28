import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './data/localDb/local_db.dart';
import './app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'domain/utils/bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await LocalDb.init();
  if (FirebaseAuth.instance.currentUser == null) {
    await LocalDb.clearTrip();
    await FirebaseAuth.instance.signInAnonymously();
  }
  Bloc.observer = SimpleBlocObserver();
  runApp(const App());
}
