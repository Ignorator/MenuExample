// ignore_for_file: directives_ordering, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import '../page/list_page.dart';
import '../provider/note_provider.dart';

late DbMenuProvider menuItemProvider;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var packageName = 'com.menu.example';

  var databaseFactory = getDatabaseFactory(packageName: packageName);

  menuItemProvider = DbMenuProvider(databaseFactory);
  // devPrint('/notepad Starting');
  await menuItemProvider.ready;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu_example',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with 'flutter run'. You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // 'hot reload' (press 'r' in the console where you ran 'flutter run',
        // or simply save your changes to 'hot reload' in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.brown,
      ),
      home: NoteListPage(),
    );
  }
}
