import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'home_screen.dart';
import 'tour_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Show splash briefly, then decide next screen
    await Future.delayed(const Duration(milliseconds: 1200));

    final db = Provider.of<DatabaseService>(context, listen: false);
    bool shown = false;
    try {
      final v = await db.getSetting<bool>('tour_shown');
      shown = v == true;
    } catch (_) {
      shown = false;
    }

    if (!mounted) return;

    if (shown) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TourScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo/logo-main.png', width: 140, height: 140),
            const SizedBox(height: 16),
            Text('Quicknotes', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
