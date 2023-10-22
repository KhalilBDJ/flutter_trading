import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'classes/User.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}
