import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashScreen extends StatelessWidget {
  const CrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: ElevatedButton(onPressed: (){
      FirebaseCrashlytics.instance.crash();
    },child: Text('Crash App'),),);
  }
}
