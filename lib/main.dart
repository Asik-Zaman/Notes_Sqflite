import 'package:flutter/material.dart';
import 'package:notes_sqflite/DBHelper/db_helper.dart';
import 'package:notes_sqflite/Pages/notes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().db;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: NotePage(),
    );
  }
}
