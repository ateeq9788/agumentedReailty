import 'dart:async';  // Import Timer
import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/Widgets/buildDot.dart';  // Custom dot widget
import 'package:agumented_reality_shopping_store/Screens/LoginScreen.dart';

class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;  // Declare a Timer

  // List of images to display
  final List<String> _images = [
    'assets/images/first.jpg',
    'assets/images/second.png',
    'assets/images/third.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();  // Start the timer
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _timer?.cancel();  // Cancel the timer if the last page is reached
        // Navigate to the next screen
        return;
      }
      _pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    });
  }

  void _onNextButtonPressed() {
    if (_currentPage < _images.length - 1) {
      _currentPage++;
      _pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    } else {
      // Navigate to the next screen with animation
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Loginscreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Start from the bottom
            const end = Offset.zero; // End at the center
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index; // Update the current page index
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _images[index],  // Load from assets
                      fit: BoxFit.cover,
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _images.length,
                                (index) => buildDot(index, _currentPage),  // Pass _currentPage as parameter
                          ),
                        ),
                        // Show the "Next" button only on the last page
                        if (_currentPage == _images.length - 1)
                          TextButton(
                            onPressed: _onNextButtonPressed,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Ensures the button size wraps content
                              children: [
                                Text(
                                  'Next', // You can add text here if needed
                                  style: TextStyle(color: Colors.white), // Text color
                                ),
                                SizedBox(width: 8), // Spacing between text and icon
                                Icon(
                                  Icons.arrow_right_alt,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
