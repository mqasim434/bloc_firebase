import 'package:flutter/material.dart';

class AdMobScreen extends StatefulWidget {
  const AdMobScreen({super.key});

  @override
  State<AdMobScreen> createState() => _AdMobScreenState();
}

class _AdMobScreenState extends State<AdMobScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
          },
          child: Text('Show Ad'),
        ),
      ),
    );
  }
}
