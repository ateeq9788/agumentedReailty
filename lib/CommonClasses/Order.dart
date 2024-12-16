import 'package:agumented_reality_shopping_store/CommonClasses/CartItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class OrderData {
  final String userId;
  final String address;
  final List<Cartitem> cartItems;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime? createdAt;
  final String? status;
  final String? cancelReason;

  OrderData({
    required this.userId,
    required this.address,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.createdAt,
    this.status,
    this.cancelReason,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'userId': userId,
  //     'cartItems': cartItems.map((item) => item.toMap()).toList(),
  //     'subtotal': subtotal,
  //     'tax': tax,
  //     'total': total,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   };
  // }
// fromMap method to convert Firestore document to OrderData object
//   factory OrderData.fromMap(Map<String, dynamic> map) {
//     return OrderData(
//       userId: map['userId'] ?? '',
//       cartItems: List<Cartitem>.from(
//         (map['cartItems'] as List).map((item) => Cartitem.fromMap(item)),
//       ),
//       subtotal: map['subtotal']?.toDouble() ?? 0.0,
//       tax: map['tax']?.toDouble() ?? 0.0,
//       total: map['total']?.toDouble() ?? 0.0,
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//     );
//   }\
  // Convert OrderData to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'address':address,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),  // Ensure Cartitem has a toMap method
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.timestamp()),  // Convert DateTime to Firestore Timestamp
      'status' : status,
      'cancelReason' : cancelReason,
    };
  }

  // fromMap method to convert Firestore document to OrderData object
  factory OrderData.fromMap(Map<String, dynamic> map) {
    return OrderData(
      userId: map['userId'] ?? '',
      address: map['address'] ?? '',
      cartItems: List<Cartitem>.from(
        (map['cartItems'] as List).map((item) => Cartitem.fromMap(item)),
      ),
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      cancelReason: map['cancelReason'] ?? '',
      status: map['status'] ?? ''
    );
  }
}
