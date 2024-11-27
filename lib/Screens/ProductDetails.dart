import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/Screens/AR_ObjectScreen.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Product.dart';

class Productdetails extends StatefulWidget {
  final Product product;

  const Productdetails({super.key, required this.product});

  @override
  State<Productdetails> createState() => _ProductdetailsState();
}

class _ProductdetailsState extends State<Productdetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20),), // Handle long names
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height - 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,// Align text to the start
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Stack(
                      children: [
                        // Display product image
                        Image.network(
                          widget.product.productImg, // Use product image URL
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to asset if image URL fails
                            return Image.asset(
                              'assets/images/testImg.png',
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Price: \$${widget.product.price.toStringAsFixed(2)}', // Display product price
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),textAlign: TextAlign.right,
                    ),
                  ),),
                  //SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      widget.product.desc, // Use product description
                      textAlign: TextAlign.justify,
                      // Handle overflow
                    ),
                  ),
                  SizedBox(height: 20),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      child: Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue,
                              blurRadius: 5.0,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.mobile_friendly_sharp, color: Colors.white),
                              SizedBox(width: 5),
                              Expanded(child: Text(
                                'Try Virtually (AR View)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                              ),)
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        // Navigate to AR View
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ARObjectScreen(imgUrl: widget.product.productImg),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
