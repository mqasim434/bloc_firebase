import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    150,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.pexels.com/photos/15422042/pexels-photo-15422042/free-photo-of-a-man-with-glasses-and-a-sweater-on.jpeg'),
                  ),
                ),
              ),
              const Text(
                'Muhammad Qasim',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text('mq30003@gmail.com'),
              const Text('+92 304 6268933'),

            ],
          ),
        ),
      ),
    );
  }
}
