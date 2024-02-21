import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/profile_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<UserModel>(
              stream: profileProvider.getUserProfile(
                  registrationProvider.currentUser!.email.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(
                          child: Stack(
                            children: [
                              snapshot.data!
                                  .imageUrl
                                  .toString()
                                  .isNotEmpty
                                  ? Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        snapshot.data!.imageUrl.toString()),
                                    invertColors: true,
                                  ),
                                  borderRadius: BorderRadius.circular(150),
                                ),
                              )
                                  : Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  image: const DecorationImage(
                                    image:
                                    AssetImage('assets/icons/user.png'),
                                  ),
                                  borderRadius: BorderRadius.circular(150),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return SizedBox(
                                                height: 200,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                  children: [
                                                    const Text(
                                                      'Pick an Image',
                                                      style:
                                                      TextStyle(fontSize: 24),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        profileProvider
                                                            .pickImage(
                                                            'camera',
                                                            registrationProvider
                                                                .currentUser!
                                                                .email
                                                                .toString());
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                          minimumSize: Size(
                                                              MediaQuery
                                                                  .of(
                                                                  context)
                                                                  .size
                                                                  .width -
                                                                  20,
                                                              50)),
                                                      child: const Text(
                                                        'Camera',
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        profileProvider
                                                            .pickImage(
                                                            'gallery',
                                                            registrationProvider
                                                                .currentUser!
                                                                .email
                                                                .toString());
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        minimumSize: Size(
                                                            MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width -
                                                                20,
                                                            50),
                                                      ),
                                                      child: const Text(
                                                        'Gallery',
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text('Full Name:'),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,),
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              hintText: snapshot.data!.name,
                              hintStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.w500),
                              border: InputBorder.none
                          ),
                        ),
                      ),
                      const Text('Email: '),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                              hintText: snapshot.data!.email,
                              hintStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.w500),
                              border: InputBorder.none
                          ),
                        ),
                      ),
                      const Text('Phone Number: '),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,),
                        child: TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: snapshot.data!.phone,
                            hintStyle: const TextStyle(
                              color: Colors.white,
                                fontSize: 20, fontWeight: FontWeight.w500),
                            border: InputBorder.none
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: () {
                            if(nameController.text.isNotEmpty){
                              profileProvider.updateData('name',nameController.text ,snapshot.data!.email.toString());
                              nameController.clear();
                            }
                            if(emailController.text.isNotEmpty){
                              profileProvider.updateData('email',emailController.text ,snapshot.data!.email.toString());
                              emailController.clear();
                            }
                            if(phoneController.text.isNotEmpty){
                              profileProvider.updateData('phone',phoneController.text,snapshot.data!.email.toString());
                              phoneController.clear();
                            }
                          }, child: const Text('Update'),),
                        ],
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}