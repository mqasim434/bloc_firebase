import 'package:bloc_firebase/components/social_login_button.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:bloc_firebase/screens/profile_screen.dart';
import 'package:bloc_firebase/screens/registration_screen.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {

  SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    notificationServices.requestNotificationPermissions();
    notificationServices.refreshToken();
    notificationServices.firebaseInit(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign In to\nYour Account',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: registrationProvider.emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter email address';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: registrationProvider.passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter password';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: const Text(
                              'Forgot Password',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            registrationProvider.signInWithEmail().then((value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userModel: UserModel(
                                      name: value!.user!.displayName,
                                      email: value!.user!.email,
                                      imageUrl: value!.user!.photoURL,
                                    ),
                                  ),
                                ),
                              );
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: const Text('Sign in'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            color: Colors.white,
                            width: 100,
                            height: 1,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('OR'),
                          ),
                          Container(
                            color: Colors.white,
                            width: 100,
                            height: 1,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialLoginButton(
                            icon: 'assets/icons/google.png',
                            onPress: () => registrationProvider.signupWithGoogle(),
                          ),
                          SocialLoginButton(
                            icon: 'assets/icons/github.png',
                            onPress: () => registrationProvider.signinWithGithub(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            registrationProvider.isLoading?const CircularProgressIndicator():const SizedBox(),
          ],
        ),
      ),
    ));
  }
}
