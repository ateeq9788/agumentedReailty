import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/Screens/AdminScreens/AddProductOnStoreScreen.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Product.dart';

class AdminOrderNotificationScreen extends StatefulWidget {
  @override
  _AdminOrderNotificationScreenState createState() => _AdminOrderNotificationScreenState();
}

class _AdminOrderNotificationScreenState extends State<AdminOrderNotificationScreen> with SingleTickerProviderStateMixin {
  final CollectionReference ordersRef = FirebaseFirestore.instance.collection('adminNotifications');
  late TabController _tabController;
  String selectedFilter = 'order'; // Default filter is 'order'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Orders'),
            Tab(text: 'Others'),
          ],
          onTap: (index) {
            setState(() {
              selectedFilter = index == 0 ? 'order' : 'stock';
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef
            .where('type', isEqualTo: selectedFilter) // Filter based on selected tab
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No new notifications.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              //final orderId = order.id;
              final orderData = order.data() as Map<String, dynamic>;
              final notificationType = orderData['type'];
              print('notificationType is $notificationType');
              return notificationType == 'order' ? Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child:
                  Padding(padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text('${orderData['message']}'),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              _showConfirmationDialog(context, orderData['orderId'], 'confirmed', orderData['userId'], order.id);
                            },
                            child: Text('Confirm',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                          ),
                          SizedBox(width: 100,),
                          GestureDetector(
                            onTap: (){
                              _showConfirmationDialog(context, orderData['orderId'], 'canceled', orderData['userId'], order.id);
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),)
              ) : Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child:
                  Column(
                    children: [
                      Text('${orderData['message']}'),
                      Padding(padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Spacer(),
                          GestureDetector(
                            onTap: (){
                                fetchProduct(orderData['productId']);
                            },
                            child: Text('Add Stock',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                          ),
                        ],
                       ),
                      )
                    ],
                  )
              );
            },
          );
        },
      ),
    );
  }

  void _updateOrderStatus(String orderId, String status,String userId,String? cancelReason,String docId) async {
    final CollectionReference selectedOrderRef = FirebaseFirestore.instance.collection('orders');
    try {
      await selectedOrderRef.doc(orderId).update({'status': status,'cancelReason' : cancelReason}).then((_)async{
        await ordersRef.doc(docId).delete();
      }).then((_) async{
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': userId,
          'message': status == 'confirmed' ? 'Your order has been confirmed successfully. Order ID: ${orderId}' : 'Your order has been cancelled. Order ID: ${orderId}',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'address': '',
        }).then((_){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order has been ${status}.')),
          );
        });
      });
      print('Order $orderId updated to $status.');
    } catch (e) {
      print('Error updating order: $e');
    }
  }
  
  Future<void> fetchProduct(String productId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (snapshot.exists) {
        final product = Product(
          id: snapshot.id,
          name: snapshot['name'],
          company: snapshot['company'],
          desc: snapshot['desc'],
          price: snapshot['price'],
          productImg: snapshot['productImg'],
          categoryId: snapshot['categoryId'],
          stock: snapshot['stock'],
          isFavourite: false
        );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Addproductonstorescreen(product: product,isEdit: true,),
              ),
            );


        print("Product added: ${product.name}");
      } else {
        print("Product with ID $productId does not exist.");
      }
    } catch (e) {
      print("Error fetching product: $e");
    }
  }



  void _showConfirmationDialog(
      BuildContext context, String orderId, String status, String userId,String docId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: status == 'canceled'
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please provide a reason for cancellation:'),
              SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          )
              : Text('Are you sure you want to mark this order as $status?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (status == 'canceled') {
                  final cancelReason = reasonController.text.trim();
                  if (cancelReason.isEmpty) {
                    // Show an error if the reason is not provided
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cancellation reason is required')),
                    );
                    return;
                  }
                  _updateOrderStatus(orderId, status, userId, cancelReason, docId);
                } else {
                  _updateOrderStatus(orderId, status, userId, null, docId);
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
