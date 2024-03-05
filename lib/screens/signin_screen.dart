import 'package:bloc_firebase/components/social_login_button.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/otp_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/registration_screen.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard.dart';

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
    Connectivity connectivity = Connectivity();
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final otpProvider = Provider.of<OTPProvider>(context);
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
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
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
                                  onTap: () {
                                    var emailController = TextEditingController();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            child: SizedBox(
                                              height: 300,
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                                  children: [
                                                    TextFormField(
                                                      controller: emailController,
                                                      decoration: InputDecoration(
                                                          labelText: 'Enter Email',
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                          )),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        const Text('Enable Email'),
                                                        Checkbox(
                                                            value: true,
                                                            onChanged: (value) {
                                                              otpProvider.switchEmailPhone();
                                                            }),
                                                      ],
                                                    ),
                                                    TextFormField(
                                                      controller: emailController,
                                                      decoration: InputDecoration(
                                                          labelText: 'Enter Phone',
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                          )),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        const Text('Enable Phone'),
                                                        Checkbox(
                                                            value: false,
                                                            onChanged: (value) {
                                                              otpProvider.switchEmailPhone();
                                                              print('phone ${otpProvider.isPhoneChecked}');
                                                            }),
                                                      ],
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if (emailController
                                                            .text.isNotEmpty) {
                                                          otpProvider
                                                              .validateEmail(
                                                              emailController
                                                                  .text)
                                                              .then((value) {
                                                            if (value) {
                                                              otpProvider
                                                                  .resetPasswordByEmail(
                                                                  emailController
                                                                      .text,
                                                                  context);
                                                            } else {}
                                                          });
                                                        }
                                                      },
                                                      child: const Text(
                                                        'Send OTP',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
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
                                        builder: (context) =>
                                        const RegistrationScreen(),
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
                                  registrationProvider
                                      .signInWithEmail()
                                      .then((value) {
                                    chatProvider.changeOnlineStatus(
                                        value.user!.email.toString(), true);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Dashboard(),
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
                                  onPress: () =>
                                      registrationProvider.signupWithGoogle(),
                                ),
                                SocialLoginButton(
                                  icon: 'assets/icons/github.png',
                                  onPress: () =>
                                      registrationProvider.signinWithGithub(),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  registrationProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox(),
                ],
              ),
            ),
      ),
    );
  }
}
