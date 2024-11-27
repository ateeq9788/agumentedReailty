import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Product.dart';

class FavoritesScreen extends StatefulWidget {
  final String userId;
  FavoritesScreen({required this.userId});
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    setState(() {
      isLoading = true;
    });

    // Fetch favorite product IDs from Firestore
    QuerySnapshot favSnapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: widget.userId) // Replace with actual user ID
        .get();

    List<String> favoriteProductIds = favSnapshot.docs.map((doc) => doc['productId'].toString()).toList();

    // Fetch product details based on favorite IDs
    if (favoriteProductIds.isNotEmpty) {
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: favoriteProductIds)
          .get();

      favoriteProducts = productSnapshot.docs.map((doc) {
        return Product(
          id: doc.id,
          name: doc['name'],
          company: doc['company'],
          desc: doc['desc'],
          price: doc['price'],
          productImg: doc['productImg'],
          categoryId: doc['categoryId'],
          stock: doc['stock'],
          isFavourite: true, // They are favorites
        );
      }).toList();
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
        title: Text('Favorite Products'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteProducts.isEmpty
          ? Center(child: Text('No favorite products found.'))
          : Padding(padding: EdgeInsets.all(10),child: ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];
          return Card(
            color: Colors.white,
            elevation: 8,
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: Image.network(product.productImg, width: 50, height: 50),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(
                  product.isFavourite ?? false ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavourite ?? false ? Colors.red : null,
                ),
                onPressed: () {
                  // Logic to toggle favorite status can go here
                  // _toggleFavorite(product.id, product.isFavourite);
                },
              ),
            ),
          );
        },
      ),)
    );
  }
}
