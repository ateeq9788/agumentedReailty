import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  VoidCallback? togglePasswordVisibility,
}) {

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0), // Circular corner radius
      boxShadow: [
        BoxShadow(
          color: Colors.black26, // Shadow color
          blurRadius: 5.0, // Blur radius for the shadow
          offset: Offset(1, 2), // Shadow position
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Circular corner radius
          borderSide: BorderSide.none, // No visible border
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        suffixIcon: (hintText == 'Password' || hintText == 'Confirm Password')
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: togglePasswordVisibility,
        )
            : null,
      ),
    ),
  );
}