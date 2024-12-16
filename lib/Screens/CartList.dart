import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/CartItem.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Order.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Notification.dart';
import 'package:agumented_reality_shopping_store/Screens/CheckoutScreen.dart';

class CartList extends StatefulWidget {
  final String userId;

  CartList({required this.userId});

  @override
  _CartListState createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  List<Cartitem> cartItems = [];
  bool isLoading = true;
  List<String> outOfStockProducts = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
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

  removeItemFromCartList(String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: widget.userId ?? '')
        .where('productId', isEqualTo: productId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // If the product exists, update the quantity
      DocumentReference docRef = snapshot.docs.first.reference;
      // await docRef.update({
      //   'quantity': FieldValue.increment(quantity), // Increment quantity
      // });
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


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "Data from CartList");
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Cart Items'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
            ? Center(child: Text('No products found in Cart.'))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartItems[index];
                  return Dismissible(
                    key: Key(product.name),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      removeItem(index);
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              product.productImg,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.bold)),
                                  Text(
                                      '\$${product.price.toStringAsFixed(2)}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if ((product.quantity ?? 1) > 1) {
                                              updateCartItemQty(product.id, false);
                                              product.quantity = (product.quantity ?? 1) - 1;
                                              if((product.quantity ?? 0) < (product.stock ?? 0)){
                                                if(outOfStockProducts.contains(product.id)){
                                                  outOfStockProducts.remove(product.id);
                                                }
                                              }
                                            } else {
                                              _showConfirmationDialog(context, index, product.id, false);
                                            }
                                          });
                                        },
                                      ),
                                      Text(product.quantity
                                          .toString()),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          if((product.quantity ?? 0) < (product.stock ?? 0)){
                                            setState(() {
                                              updateCartItemQty(product.id, true);
                                              product.quantity = (product.quantity ?? 1) + 1;
                                              if(((product.quantity ?? 0) == (product.stock ?? 0)) && ((product.quantity ?? 0) > 0)){
                                                if (outOfStockProducts.contains(product.id) == false){
                                                  outOfStockProducts.add(product.id);
                                                }
                                              }
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
                            ),
                            Text(
                              '\$${(product.price * (product.quantity ?? 1)).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              height: 20,
              color: Colors.transparent,
            ),
            Container(
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
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          //_showConfirmationDialog(context, 0, '', true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Checkoutscreen(userId: widget.userId,outOfStockProducts: outOfStockProducts,)),
                          );
                        },
                        child: Text('Proceed to Checkout',
                            style: TextStyle(fontSize: 16.5,color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size(220, 40),
                          shadowColor: Colors.grey,
                          elevation: 5
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
}