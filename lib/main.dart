import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(db: AppDatabase()));
}

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '음양력 달력',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: CalendarScreen(db: db),
    );
  }
}
