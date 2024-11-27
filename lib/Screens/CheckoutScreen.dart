import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Order.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/CartItem.dart';


class Checkoutscreen extends StatefulWidget {
  final String userId;
  Checkoutscreen({required this.userId});

  @override
  State<Checkoutscreen> createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<Checkoutscreen> {
  List<Cartitem> cartItems = [];
  bool isLoading = true;
  String? fname;
  String? lname;
  bool isEditable = false;
  String? address;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCartItems().then((_){
      getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildCartItem(),
              SizedBox(height: 10),
              _buildPaymentMethodSection(),
              SizedBox(height: 10),
              _buildShippingAddressSection(),
              SizedBox(height: 10),
              _buildOrderSummarySection(),
              //Spacer(),
              SizedBox(height: 10,),
              _buildSubmitOrderButton(),
            ],
          ),
        ),
      )
     );
  }
  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });

    // Fetch cart product IDs from Firestore
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: widget.userId)
        .get();

    List<String> addInCartIds =
    cartSnapshot.docs.map((doc) => doc['productId'].toString()).toList();

    // Fetch product details based on cart IDs
    if (addInCartIds.isNotEmpty) {
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: addInCartIds)
          .get();

      cartItems = productSnapshot.docs.map((doc) {
        return Cartitem(
            id: doc.id,
            name: doc['name'],
            company: doc['company'],
            desc: doc['desc'],
            price: doc['price'],
            stock: doc['stock'],
            productImg: doc['productImg'],
            categoryId: doc['categoryId'],
            quantity: cartSnapshot.docs
                .map(
                  (doc) => doc['quantity'] ?? 1,
            )
                .first);
      }).toList();
    }

    setState(() {
      isLoading = false;
    });
  }
  Widget _buildCartItem() {
    return SizedBox(
      height: 120, // Specify height to prevent layout issues
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final product = cartItems[index];
          return Card(
            color: Colors.white,
            elevation: 5,
            margin: EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.network(
                    product.productImg,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text('\$${product.price.toStringAsFixed(2)}'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if ((product.quantity ?? 1) > 1) {
                                  updateCartItemQty(product.id, false);
                                  product.quantity = (product.quantity ?? 1) - 1;
                                } else {
                                  _showConfirmationDialog(context, index, product.id, false);
                                }
                              });
                            },
                          ),
                          Text(product.quantity.toString()),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {

                              if((product.quantity ?? 0) < (product.stock ?? 0)){
                                setState(() {
                                  updateCartItemQty(product.id, true);
                                  product.quantity = (product.quantity ?? 1) + 1;
                                });
                              }
                              else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No more stock available.')),
                                );
                              }

                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '\$${(product.price * (product.quantity ?? 1)).toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> updateCartItemQty(String productID, bool isAdd) async {
    // Fetch the cart item document based on userId and productId
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: widget.userId)
        .where('productId', isEqualTo: productID)
        .get();

    if (cartSnapshot.docs.isNotEmpty) {
      var doc = cartSnapshot.docs.first;
      await doc.reference.update({
        'quantity': isAdd ? FieldValue.increment(1) : FieldValue.increment(-1),
      }).then((_) {
        //fetchCartItems();
      });
    }
  }
  void _showConfirmationDialog(
      BuildContext context, int index, String productid,bool isCheckout) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation!'),
          content: Text(isCheckout ? 'Are you sure you want to checkout?' :'Are you sure you want to remove this item from cart?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // Perform the action here
                Navigator.of(context).pop();
                if(isCheckout){
                  checkout();
                }
                else
                {
                  setState(() {
                    removeItem(index);
                    removeItemFromCartList(productid);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Item removed from cart successfully.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  double getTotalPrice() {
    return cartItems.fold(
        0, (total, item) => total + (item.price * (item.quantity ?? 1)));
  }

  double getTotalTax() {
    return cartItems.fold(
        0, (total, item) => ((17/100) * (getTotalPrice())));
  }
  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }
  getUserData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstname = prefs.getString('fname').toString();
    String lastname = prefs.getString('lname').toString();
    setState(() {
      fname = firstname;
      lname = lastname;
    });
  }
  removeItemFromCartList(String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: widget.userId ?? '')
        .where('productId', isEqualTo: productId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // If the product exists, update the quantity
      DocumentReference docRef = snapshot.docs.first.reference;

      await docRef.delete();
      //showSnackBar('Item removed from cart!');
    }
  }
  Future<void> checkout() async {
    setState(() {
      isLoading = true;
    });

    if (cartItems.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    double subtotal = getTotalPrice();
    double tax = getTotalTax();
    double total = subtotal + tax;

    OrderData order = OrderData(
      userId: widget.userId,
      cartItems: cartItems,
      subtotal: subtotal,
      tax: tax,
      total: total,
      address: ''
    );

    try {
      // Save the order to Firestore
      DocumentReference orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(order.toMap());

      // After order is placed, send notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': widget.userId,
        'message': 'Your order has been placed successfully. Order ID: ${orderRef.id}',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'address': address ?? "",
      });

      // Remove each cart item after successful order placement
      for (var item in cartItems) {
        await removeItemFromCartList(item.id);
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your order has been processed successfully.'),
          duration: Duration(seconds: 3),  // Time the snackbar is visible
        ),
      );
      // Navigate back after checkout
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false; // Ensure loading is turned off in case of error
      });

      print("Failed to complete checkout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed. Please try again.')),
      );
    }
  }
  Widget _buildPaymentMethodSection() {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment methods',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/round.png',height: 15,width: 15,),
                SizedBox(width: 10,),
                Expanded(child: Text('Cash On Delivery'))
              ],
            ),
          ],
        ),),
    );
  }

  Widget _buildShippingAddressSection() {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shipping Address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 3),
                      Text("$fname $lname", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your address',
                      labelText: 'Address',
                    ),
                    maxLines: null, // Allows unlimited lines
                    keyboardType: TextInputType.multiline,
                    enabled: isEditable, // Toggles editability
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isEditable = !isEditable;
                  address = _addressController.text;
                });
              },
              child: Text(isEditable ? "Done" : "Edit"),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDiscountCodeSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Discount Code",
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(onPressed: () {}, child: Text("Apply")),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ), // Only top left and right corners rounded
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.15), // Shadow color
          //   blurRadius: 6, // How blurry the shadow is
          //   offset: Offset(0, 3), // Vertical shadow position (bottom shadow)
          // ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Shadow color
            blurRadius: 6, // How blurry the shadow is
            offset: Offset(0, -3), // Top shadow position
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal:',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('\$${getTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax 17% :',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('\$${getTotalTax().toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.black12,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('\$${(getTotalPrice() + getTotalTax()).toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        Text(value, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSubmitOrderButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
           if(address == null)
             {
               showSimpleDialog(context);
             }
           else
             {
               _showConfirmationDialog(context, 0, '', true);
             }

        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text("Submit Order", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  void showSimpleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Address"),
          content: Text("Please enter the address to continue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
