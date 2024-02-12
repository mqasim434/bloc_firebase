import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    TextEditingController phoneController = TextEditingController();
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              onTap: () {
                registrationProvider.signupWithGoogle().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userModel: UserModel(
                          name: value!.displayName,
                          email: value!.email,
                          phone: value!.phoneNumber,
                          imageUrl: value!.photoURL,
                        ),
                      ),
                    ),
                  );
                });
              },
              leading: const Icon(Icons.login),
              title: const Text(
                'Continue with Google',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {},
              leading: const Icon(Icons.login),
              title: const Text(
                'Continue with Facebook',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                registrationProvider.signInWithTwitter();
              },
              leading: const Icon(Icons.login),
              title: const Text(
                'Continue with Twitter',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                registrationProvider.signinWithGithub().then((value) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userModel: UserModel(
                        name: value!.user!.displayName,
                        email: value!.user!.email,
                        phone: value!.user!.phoneNumber,
                        imageUrl: value!.user!.photoURL,
                      ),
                    ),
                  ),);
                });
              },
              leading: const Icon(Icons.login),
              title: const Text(
                'Continue with Github',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {},
              leading: const Icon(Icons.login),
              title: const Text(
                'Continue with Apple',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 200,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: phoneController,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                registrationProvider.signinWithPhone(context);
                              },
                              child: const Text(
                                'Send Code',
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
              leading: const Icon(Icons.login),
              title: const Text(
                'Signup with Phone',
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
