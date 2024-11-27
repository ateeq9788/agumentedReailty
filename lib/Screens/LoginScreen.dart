import 'package:agumented_reality_shopping_store/Screens/ProductList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../Widgets/TextFieldCustomWidget.dart';
import 'SignUpScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Constants.dart' as Constantss;
import 'package:agumented_reality_shopping_store/CommonClasses/SharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordObscured = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: Text('Log In',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 64.0,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                //SizedBox(height: 20,),
                Text('Log In',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 24),),
                SizedBox(height: 40,),
                buildTextField(controller: _emailController, hintText: 'Email', icon: Icons.email,keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16.0),
                buildTextField(controller: _passwordController, hintText: "Password", icon: Icons.password,obscureText: _isPasswordObscured,togglePasswordVisibility: (){
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                }),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: isLoading
                      ? const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.white),
                  )
                      : const Text('Sign in'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Container(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      child: Text('Sign up here',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w700,fontSize: 15),),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpScreen()));
                      },
                    )
                  ],
                ),)
              ],
            )
          ),
        ),
      ),
    );
  }
  Future<void> _loadUserData(String userid) async {

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(userid).get();
    if (userDoc.exists) {
      File? _imageFile;
      print('user exist');

        if (userDoc['profileImage'] != null) {
          _imageFile = File(userDoc['profileImage']);
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fname', userDoc['fname']);
        await prefs.setString('lname', userDoc['lname']);
        await prefs.setString('email', userDoc['email']);
        await prefs.setBool('isAdmin', userDoc['isAdmin']);
        await prefs.setString('profileImage', userDoc['profileImage']);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Productlist()));
    }
    else
    {
      validationAlert("Error!", 'User not found!');
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // User is now signed in
      User? user = userCredential.user;
      print("User signed in: ${user?.email} and user id ${user?.uid}");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user?.uid ?? '');
      
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        isLoading = false;
      });
      _loadUserData(user?.uid ?? "");
     
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            print('No user found for that email.');
            validationAlert("Error!", 'No user found for that email.');
            break;
          case 'wrong-password':
            print('Wrong password provided for that user.');
            validationAlert("Error!", 'Wrong password provided for that user.');
            break;
          default:
            print('Error: ${e.message}');
            validationAlert("Error!", '${e.message}');
        }
      } else {
        print('Error: $e');
      }
    }
  }
  void _submitForm(){
    String email = _emailController.text;
    String password = _passwordController.text;
    if (email.isEmpty){
      validationAlert('Submission Error!', 'Please Enter Email Address.');
      return;
    }

    if (password.isEmpty){
      validationAlert('Submission Error!', 'Please Enter Password.');
      return;
    }
    else{
      print('Email: $email');
      print('Password: $password');
      setState(() {
        isLoading = true;
      });
      signInWithEmailPassword(email, password);
    }
  }
  void validationAlert(String title,String message){
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        )
    );
  }
}
