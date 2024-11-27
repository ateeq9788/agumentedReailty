class Cartitem {
  final String id;
  final String name;
  final String categoryId;
  final String productImg;
  final String desc;
  final num stock;
  final double price;
  final String company;
  final String? address;

  int? quantity;

  Cartitem({required this.id, required this.name, required this.categoryId,required this.productImg,required this.desc,required this.price,required this.company,this.quantity,this.address, required this.stock});

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'company': company,
  //     'desc': desc,
  //     'price': price,
  //     'productImg': productImg,
  //     'categoryId': categoryId,
  //     'quantity': quantity ?? 1, // Default to 1 if quantity is null
  //   };
  // }
  // factory Cartitem.fromMap(Map<String, dynamic> map) {
  //   return Cartitem(
  //     id: map['id'] ?? '',
  //     name: map['name'] ?? '',
  //     company: map['company'] ?? '',
  //     desc: map['desc'] ?? '',
  //     price: map['price']?.toDouble() ?? 0.0,
  //     productImg: map['productImg'] ?? '',
  //     categoryId: map['categoryId'] ?? '',
  //     quantity: map['quantity'] ?? 1,
  //   );
  // }
// Convert Cartitem to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address' : address,
      'company': company,
      'desc': desc,
      'price': price,
      'stock':stock,
      'productImg': productImg,
      'categoryId': categoryId,
      'quantity': quantity,
    };
  }

  // fromMap method to convert Firestore document to Cartitem object
  factory Cartitem.fromMap(Map<String, dynamic> map) {
    return Cartitem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      company: map['company'] ?? '',
      desc: map['desc'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
      productImg: map['productImg'] ?? '',
      categoryId: map['categoryId'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
}