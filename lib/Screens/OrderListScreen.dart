import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Order.dart';
import 'package:agumented_reality_shopping_store/Screens/OrderDetailScreen.dart';

class OrderListScreen extends StatefulWidget {
  final String userId;

  OrderListScreen({required this.userId});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  List<OrderData> orders = [];
  List<OrderData> filteredOrders = [];
  bool isLoading = true;
  String selectedStatus = "Pending"; // Default filter

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
          .where('userId', isEqualTo: widget.userId)
          .get();

      orders = snapshot.docs
          .map((doc) => OrderData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      filterOrders();
    } catch (e) {
      print("Error fetching orders: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterOrders() {
    setState(() {
      filteredOrders = orders
          .where((order) => order.status?.toLowerCase() == selectedStatus.toLowerCase())
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Order List'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Segmented Control
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSegmentButton("Pending"),
                _buildSegmentButton("Confirmed"),
                _buildSegmentButton("Canceled"),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? Center(child: Text('No $selectedStatus orders found.'))
                : ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Order ID: ${order.orderId}',
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: order.cartItems
                                      .map((item) => Text(
                                    '${item.name} (x${item.quantity})',
                                    style: TextStyle(
                                        fontSize: 14),
                                  ))
                                      .toList(),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Status: ${order.status}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: order.status == 'canceled'
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                                if (order.status == 'canceled')
                                  Text(
                                    'Reason: ${order.cancelReason ?? "N/A"}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Text(
                                'Total: \$${order.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String status) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
          filterOrders();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedStatus == status ? Colors.blue : Colors.white,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: selectedStatus == status ? Colors.white : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
