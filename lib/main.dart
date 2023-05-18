import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valorant_daily_store/models/account_model.dart';
import 'package:valorant_daily_store/providers/account_provider.dart';

import 'app.dart';
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }

  @override
  noSuchMethod(Invocation invocation) {
    // your implementation here
  }
}
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  // Hive init
  await Hive.initFlutter();

  // Open Accounts Box
  Hive.registerAdapter(AccountAdapter());
  await Hive.openBox<Account>('accounts');

  runApp(
    ChangeNotifierProvider<AccountProvider>(
      create: (BuildContext context) => AccountProvider(),
      child: const MyApp(),
    ),
  );
}
