import 'dart:io';
import 'package:farm_link/bloc/authentication/auth_bloc.dart';
import 'package:farm_link/bloc/authentication/auth_event.dart';
import 'package:farm_link/bloc/authentication/auth_state.dart';
import 'package:farm_link/pages/contact_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool visiblePassword = true;

  File? _selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return ContactListPage();
        }

        if (state is AuthStateLoggedOut) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, bottom: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Εγγραφή:',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Εισάγεται τα στοιχεία σας για να δημιουργήσετε λογαριασμό ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage('assets/user.png')
                              as ImageProvider,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.alternate_email,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            height: 50,
                            width: 250,
                            child: TextField(
                              controller: emailController,
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                hintText: 'E-mail ID',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            height: 50,
                            width: 250,
                            child: TextField(
                              controller: usernameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                hintText: 'Ειδικότητα',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.password,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            height: 50,
                            width: 250,
                            child: TextField(
                              controller: passwordController,
                              obscureText: visiblePassword,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: visiblePassword
                                        ? Colors.grey.shade500
                                        : Colors.green,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      visiblePassword = !visiblePassword;
                                    });
                                  },
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                hintText: 'Κωδικός',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: (!state.successful && state.error.isNotEmpty)
                        ? Text(
                            textAlign: TextAlign.center,
                            state.error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          state.isLoading
                              ? const CircularProgressIndicator()
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 250,
                                    height: 50,
                                    child: MaterialButton(
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                              AuthEventRegister(
                                                email: emailController.text,
                                                password:
                                                    passwordController.text,
                                                username:
                                                    usernameController.text,
                                                image: _selectedImage,
                                              ),
                                            );
                                      },
                                      color: Colors.green,
                                      child: const Text('Εγγραφή'),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
