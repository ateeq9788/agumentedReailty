import 'dart:async';
import 'package:agumented_reality_shopping_store/Screens/LoginScreen.dart';
import 'package:agumented_reality_shopping_store/Screens/SignUpScreen.dart';
import 'package:agumented_reality_shopping_store/Screens/ProductList.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agumented_reality_shopping_store/Screens/LaunchScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/SharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBJo4Yj6wNrcY56qmY-uhYcIwgrWi0FhbM",
            appId: "1:1067165408764:ios:1ae7d0df8b0379e36b2679",
            messagingSenderId: "1067165408764",
            projectId: "shoppingstore-bb8ec",
            storageBucket:'shoppingstore-bb8ec.appspot.com'));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    // setState(() {
    //   isLoading = true;
    // });
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    }
  }

  void _navigateToHome() {
    FirebaseAuth.instance.currentUser;
    _loadUserData(_user?.uid ?? '', context).then((_){

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(isloading: isLoading),
    );
  }
}

Future<void> _loadUserData(String userid,BuildContext context) async {

  final userDoc =
  await FirebaseFirestore.instance.collection('users').doc(userid).get();
  if (userDoc.exists) {
      print('user exist');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fname', userDoc['fname']);
      await prefs.setString('lname', userDoc['lname']);
      await prefs.setString('email', userDoc['email']);
      await prefs.setBool('isAdmin', userDoc['isAdmin']);
      await prefs.setString('profileImage', userDoc['profileImage']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Productlist()),
    );
  }
  else
    {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LaunchScreen()),
      );
    }
}
class SplashScreen extends StatelessWidget {
   User? _user = FirebaseAuth.instance.currentUser;
   bool isloading;
   SplashScreen({required this.isloading});

  @override
  Widget build(BuildContext context) {
    // Simulate a loading process

    Future.delayed(Duration(seconds: 1), () {
      if(_user == null){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LaunchScreen()),
        );
      }
      else
        {
          _loadUserData(_user?.uid ?? '',context);
        }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Welcome to AR Shopping Store.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),)
    );
  }
}

