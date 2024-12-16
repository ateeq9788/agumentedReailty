import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Notification.dart'; // Assuming you have this class defined
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  NotificationsScreen({required this.userId});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Notifications> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch notifications for the specific userId
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: widget.userId)
          .get();
        if (snapshot.docs.isNotEmpty){
          await markAllNotificationsAsRead(widget.userId);
        }
      notifications = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>; // Correct cast to Map<String, dynamic>
        return Notifications.fromMap(doc.id, data); // Assuming this constructor exists
      }).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      // Query to get all notifications where isRead is false for the given user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No unread notifications found.');
        return;
      }
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      print('All notifications marked as read successfully.');
    } catch (e) {
      print('Failed to mark notifications as read: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      Navigator.pop(context, "Data from CartList");
      return true;
    },child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(child: Text('No notifications found.'))
          : Padding(padding: EdgeInsets.all(10),child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
              color: Colors.white,
              elevation: 8,
              child: Padding(padding: EdgeInsets.all(9),child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(notification.message),
                  SizedBox(height: 10,),
                  Align(alignment: Alignment.bottomRight,child:
                  Text('${DateFormat('EEEE, MMM d, y h:mm a').format(notification.timestamp ?? DateTime.now())}', style: TextStyle(fontSize: 12,color: Colors.grey)),)
                ],
              ),
              )
          );
        },
      ),
      ),
    ),);
  }
}
