import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Constants.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Category.dart';


class Categoriesscreen extends StatefulWidget {
  const Categoriesscreen({super.key});

  @override
  State<Categoriesscreen> createState() => _CategoriesscreenState();
}

class _CategoriesscreenState extends State<Categoriesscreen> {

  Category? selectedCategory;
  // Variable to store selected icon
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Icon Dropdown Selector')),
      body: Center(
        child:
        DropdownButton<Category>(
          hint: Text("Choose a Category"),
          value: selectedCategory,
          onChanged: (Category? newValue) {
            setState(() {
              selectedCategory = newValue; // Save the selected category
            });
          },
          items: categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: [
                  // Optionally show the category icon
                  Image.asset(category.icon, width: 30, height: 30),
                  SizedBox(width: 8),
                  Text(category.title), // Display category title
                ],
              ),
            );
          }).toList(),
        ),
       ),
    );
  }
}
