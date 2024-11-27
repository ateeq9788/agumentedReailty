import 'package:flutter/material.dart';
import '../Widgets/TextFieldCustomWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Constants.dart' as Constantss;


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  static RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool isloading = false;

  void _submitForm() {

      String fName = _fNameController.text;
      String lName = _lNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String confirmPaswrod = _confirmPasswordController.text;
      var isValid = _emailRegExp.hasMatch(email);
      if (fName.isEmpty){
        validationAlert('Submission Error!', 'Please Enter First Name.');
        return;
      }
      if (lName.isEmpty){
        validationAlert('Submission Error!', 'Please Enter Last Name.');
        return;
      }
      if (email.isEmpty){
        validationAlert('Submission Error!', 'Please Enter Email Address.');
        return;
      }
      if (isValid == false){
        validationAlert('Validation Error!', 'Please Enter valid Email Address.');
        return;
      }
      if (password.isEmpty){
        validationAlert('Submission Error!', 'Please Enter Password.');
        return;
      }
      if (confirmPaswrod.isEmpty || password != confirmPaswrod){
        validationAlert('Validation Error!', "Password Doesn't Match.");
        return;
      }
      else
        {
          print('First Name: $fName');
          print('Last Name: $lName');
          print('Email: $email');
          print('Password: $password');
          print('confirm password $confirmPaswrod');

          setState(() {
            isloading = true;
          });

          //Navigator.pop(context);
          _register(email, password, fName, lName);
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: Text('Sign Up',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 40,),
                const Text('Create Account',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 24),),
                const SizedBox(height: 40,),
                buildTextField(controller: _fNameController, hintText: 'First Name', icon: Icons.person),
                const SizedBox(height: 16.0),
                buildTextField(controller: _lNameController, hintText: "Last Name", icon: Icons.person),
                const SizedBox(height: 16.0),
                buildTextField(controller: _emailController, hintText: 'Email', icon: Icons.email,keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16.0),
                buildTextField(controller: _passwordController, hintText: "Password", icon: Icons.password,obscureText: _isPasswordObscured,togglePasswordVisibility: (){
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                }),
                const SizedBox(height: 16.0),
                buildTextField(controller: _confirmPasswordController, hintText: "Confirm Password", icon: Icons.password,obscureText: _isConfirmPasswordObscured,togglePasswordVisibility: (){
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                }),
                const SizedBox(height: 24.0),
                Container(height: 50,width: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue, // Background color of the container
                    borderRadius: BorderRadius.circular(25.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 7,  // Blur radius
                        offset: Offset(0, 3), // Offset in x and y direction (horizontal, vertical)
                      ),
                    ],
                  ),
                  child: isloading ? Center(child: CircularProgressIndicator(color: Colors.white,),) : GestureDetector(
                    onTap: (){
                      _submitForm();
                    },
                    child: Padding(
                        padding: EdgeInsets.all(8.0), // Padding inside the container
                        child: Center(child: Text("Sign Up",style: TextStyle(color: Colors.white,fontSize: 17),),)
                    ),
                  )
                ),
                const SizedBox(height: 24.0),
                Container(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? "),
                    GestureDetector(
                      child: Text('Log In here',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w700,fontSize: 15),),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _register(String email,String password,String fname,String lname) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User registered: ${userCredential.user!.email}");
      User? user = userCredential.user;
      if (user != null) {
        _fNameController.clear();
        _lNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        // Save additional user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'fname': fname,
          'lname' : lname,
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin' : false,
          'profileImage':''
        }).then((_){
          setState(() {
            isloading = false;
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have successfully registered!'),
            duration: Duration(seconds: 2), // Duration for how long it will be shown
            action: SnackBarAction(
              label: '', // Action button label
              onPressed: () {
                // Handle action when the user presses the button
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
      else
        {
          setState(() {
            isloading = false;
          });
        }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        validationAlert('Error!', 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        validationAlert('Error!', 'The account already exists for that email.');
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print('error occured');
      print(e);
      validationAlert('Error!', e.toString());
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
  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _fNameController.dispose();
    _lNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
