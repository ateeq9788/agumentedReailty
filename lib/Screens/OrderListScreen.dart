import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Order.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/CartItem.dart';
import 'dart:core';
import 'package:agumented_reality_shopping_store/Screens/OrderDetailScreen.dart';

class OrderListScreen extends StatefulWidget {
  final String userId; // Pass userId to fetch user's orders

  OrderListScreen({required this.userId});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<OrderData> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: widget.userId) // Optional: Order by date
          .get();

      orders = snapshot.docs
          .map((doc) => OrderData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching orders: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order List'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text('No orders found.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(8.0),
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //Text('Order ID: ${order.userId}', style: TextStyle(fontWeight: FontWeight.bold)),
                              //Text('Order Date: ${order.createdAt}'),
                              //SizedBox(height: 10),
                              // Text('Subtotal: \$${order.subtotal.toStringAsFixed(2)}'),
                              // Text('Tax: \$${order.tax.toStringAsFixed(2)}'),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    children: order.cartItems.map((item) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Items:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text('Name: ${item.name}'),
                                          Text('Quantity: ${item.quantity}'),
                                          Text('Company: ${item.company}'),
                                          //Text('Address: ${item.address}'),
                                          SizedBox(height: 30,)

                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  Expanded(child: Container(
                                    child: Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Text(
                                        'Total: \$${order.total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                                    ),
                                  ),),
                                  SizedBox(height: 10),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
