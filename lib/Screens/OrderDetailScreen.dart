import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Order.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Order.dart';
import 'package:intl/intl.dart';


class OrderDetailScreen extends StatelessWidget {
  final OrderData order;

  OrderDetailScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order Details'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Order ID: ${order.orderId}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Order Date: ${DateFormat('EEEE, MMM d, y h:mm a').format(order.createdAt ?? DateTime.now())}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Divider(),
            Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: order.cartItems.length,
                itemBuilder: (context, index) {
                  final item = order.cartItems[index];
                  return ListTile(
                    leading: Image.network(item.productImg, height: 50, width: 50),
                    title: Text(item.name),
                    subtitle: Text('Qty: ${item.quantity}, \nPrice: \$${item.price}'),
                    trailing: Text('\$${(item.price * item.quantity!).toStringAsFixed(2)}',style: TextStyle(fontSize: 17),),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${order.subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax (17%):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${order.tax.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${order.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
