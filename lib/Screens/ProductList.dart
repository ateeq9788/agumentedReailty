import 'package:agumented_reality_shopping_store/Screens/ProductDetails.dart';
import 'package:agumented_reality_shopping_store/Widgets/ProductWidget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/Screens/AdminScreens/AddProductOnStoreScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agumented_reality_shopping_store/Screens/AdminScreens/CategoriesScreen.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Constants.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Category.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Product.dart';
import 'package:agumented_reality_shopping_store/Widgets/NetworkImageWithLoader.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/SharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agumented_reality_shopping_store/Screens/FavoritesScreen.dart';
import 'package:agumented_reality_shopping_store/Screens/CartList.dart';
import 'package:agumented_reality_shopping_store/Screens/Profile.dart';
import 'package:agumented_reality_shopping_store/Screens/OrderListScreen.dart';
import 'package:agumented_reality_shopping_store/Screens/LaunchScreen.dart';
import 'package:agumented_reality_shopping_store/Screens/NotificationsScreen.dart';
import 'package:agumented_reality_shopping_store/Screens/AdminScreens/AdminNotifications.dart';

class Productlist extends StatefulWidget {
  const Productlist({super.key});

  @override
  State<Productlist> createState() => _ProductlistState();
}

class _ProductlistState extends State<Productlist> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selectIndex = 0;
  Category? selectedCategory;
  List<Product> products = [];
  bool isLoadingDataFromFS = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> favoriteProductIds = [];
  List<String> cartItemIds = [];
  String? userid;
  String? userImage;
  String? userfname;
  String? userlname;
  String? useremail;
  bool? isAdmin;
  bool isNewNotification = false;
  bool isNewNotificationOfAdmin = false;

  @override
  void initState() {
    super.initState();
    getUserDatafromPref();
    fetchDataFromfireStore(); // Fetch all products initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Products List'),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          if((isAdmin ?? false) == false) ...[
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NotificationsScreen(userId: userid ?? '')),
                    ).then((_){
                      fetchDataFromfireStore();
                    });
                  },
                ),
                if(isNewNotification)
                  Positioned(
                    right: 13,
                    top: 12,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Stack(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    padding: EdgeInsets.all(5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CartList(userId: userid ?? '')),
                        ).then((_) {
                          fetchDataFromfireStore();
                        });
                      },
                      child: Image.asset(
                        'assets/images/cart.png',
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                  if (cartItemIds.isNotEmpty)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
          if((isAdmin ?? false) == true) ...[
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AdminOrderNotificationScreen()),
                    ).then((_){
                      fetchDataFromfireStore();
                    });
                  },
                ),
                if(isNewNotificationOfAdmin)
                  Positioned(
                    right: 13,
                    top: 12,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            // Padding(
            //   padding: EdgeInsets.only(right: 15),
            //   child: Stack(
            //     children: [
            //       Container(
            //         height: 30,
            //         width: 30,
            //         padding: EdgeInsets.all(5),
            //         child: GestureDetector(
            //           onTap: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) =>
            //                       CartList(userId: userid ?? '')),
            //             ).then((_) {
            //               fetchDataFromfireStore();
            //             });
            //           },
            //           child: Image.asset(
            //             'assets/images/cart.png',
            //             height: 25,
            //             width: 25,
            //           ),
            //         ),
            //       ),
            //       if (cartItemIds.isNotEmpty)
            //         Positioned(
            //           right: 2,
            //           top: 2,
            //           child: Container(
            //             width: 9,
            //             height: 9,
            //             decoration: BoxDecoration(
            //               color: Colors.red,
            //               shape: BoxShape.circle,
            //             ),
            //           ),
            //         ),
            //     ],
            //   ),
            // )
          ]
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/second.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              accountName: Text('${userfname ?? ''} ${userlname ?? ''}'),
              accountEmail: Text(useremail ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (userImage != null || userImage != '')
                    ? NetworkImage(userImage!)
                    : AssetImage('assets/images/user.png'),
              ),
              otherAccountsPictures: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to Favorites screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(userId: userid ?? '')),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Home screen
              },
            ),
            if(!(isAdmin ?? false))...[
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favorites'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Favorites screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FavoritesScreen(userId: userid ?? '')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Cart'),
                onTap: () {
                  Navigator.pop(context);
                  var result = Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartList(userId: userid ?? '')),
                  ).then((_) {
                    fetchDataFromfireStore();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('Orders'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderListScreen(userId: userid ?? '')),
                  );
                },
              ),
            ],

            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(userId: userid ?? '')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings screen
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Help & Support screen
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                  _showConfirmationDialog(context);
                // Perform logout
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    bool isSelected = selectIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectIndex = index;
                          selectedCategory = cat;
                          _fetchProductsByCategory(selectedCategory?.id ?? '0');
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 70,
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? Colors.blue : Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Image.asset(
                                  '${cat.icon}',
                                  height: 30,
                                  width: 30,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${cat.title}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: isLoadingDataFromFS
                            ? CircularProgressIndicator()
                            : Text(selectedCategory?.id == '0' ? 'Data Not Found!' : 'No Product found for this category!'),)
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 items per row
                            crossAxisSpacing:
                                10, // Horizontal space between items
                            mainAxisSpacing: 10, // Vertical space between items
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            var img = 'assets/images/heart.png';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Productdetails(product: product)),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFE5E2DA),
                                  // Background color for the item
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(
                                          0, 3), // Changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 20,
                                            left: 40,
                                            right: 40,
                                            bottom: 0,
                                            child: NetworkImageWithLoader(
                                              imageUrl: product.productImg,
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.scaleDown,
                                            ),
                                          ),
                                          if(isAdmin == false)
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                                onTap: () {
                                                  bool isFav =
                                                      favoriteProductIds
                                                          .contains(product.id);
                                                  if((isAdmin ?? false) == false){
                                                    setState(() {
                                                      _toggleFavorite(
                                                          product.id, isFav);
                                                    });
                                                  }
                                                },
                                                child: Image.asset(color: Colors.blue,
                                                  product.isFavourite ?? false
                                                      ? 'assets/images/heartFill.png'
                                                      : 'assets/images/heart.png',
                                                  height: 25,
                                                  width: 25,
                                                )),
                                          ),
                                          if(isAdmin == true)
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    showDeleteDialog(context, product.id);
                                                  },
                                                  child: Icon(Icons.delete,color: Colors.red,size: 25,),
                                              ),
                                            ),
                                          Positioned(
                                              top: 5,
                                              left: 5,
                                              child: Column(
                                                children: [
                                                  Text('Stock',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  Text(product.stock <= 0 ? 'Out of stock' : '${product.stock ?? 0}',style: TextStyle(fontWeight: FontWeight.bold),)
                                                ],
                                              )
                                           )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(padding: EdgeInsets.all(5),child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "${product.price} \$",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),),
                                        if(isAdmin == false)
                                        GestureDetector(
                                          onTap: () {
                                            if((isAdmin ?? false) == false){
                                              print('cart tapped');
                                              String userId = userid ?? '';
                                              String productId = product.id;
                                              int quantity = 1;
                                              addToCart(userId, productId, quantity, product.stock ?? 0);
                                            }
                                          },
                                          child: Container(
                                            width: 65,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: cartItemIds
                                                  .contains(product.id)
                                                  ? Colors.blue
                                                  : Colors
                                                  .black, // Background color
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                // Top-left corner radius
                                                bottomRight: Radius.circular(
                                                    10.0), // Top-right corner radius
                                              ),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/cart.png',
                                                width: 25,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if(isAdmin == true)
                                         GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Addproductonstorescreen(product: product,isEdit: true,)),
                                              );
                                            },
                                            child: Container(
                                              width: 50,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .black, // Background color
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20.0),
                                                  // Top-left corner radius
                                                  bottomRight: Radius.circular(
                                                      10.0), // Top-right corner radius
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(Icons.edit,color: Colors.white,),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    floatingActionButton: !(isAdmin ?? false) ? null : FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Addproductonstorescreen()),
        );
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.add, color: Colors.white),
    ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation!'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async{
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();  // Firebase sign-out

                // Clear the entire navigation stack and push to the login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LaunchScreen()),
                      (Route<dynamic> route) => false, // Removes all previous routes
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context,String docid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the confirmation action here
                Navigator.of(context).pop(); // Close the dialog
                deleteDocument(docid);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
  Future<void> deleteDocument(String docid) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docid)
          .delete().then((_){
            _fetchProductsByCategory('0');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product deleted successfully!")),
        );
      });

      print("Document deleted successfully!");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  getUserDatafromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');
    String? img = prefs.getString('profileImage');
    String? fname = prefs.getString('fname');
    String? lname = prefs.getString('lname');
    String? email = prefs.getString('email');
    bool? isAdminUser = prefs.getBool('isAdmin');
    print('is user admin $isAdminUser');
     setState(() {
      userid = id;
      userImage = img;
      userfname = fname;
      userlname = lname;
      useremail = email;
      isAdmin = isAdminUser;
    });
  }

  fetchDataFromfireStore() async {
    setState(() {
      isLoadingDataFromFS = true;
    });
    if((isAdmin ?? false) == true){
      await _fetchProductsByCategory('0');
      await checkNewNotificationforAdmin();
    }
    else
      {
        await fetchfavouriteProducts();
        await _fetchProductsByCategory('0');
        await fetchCartItems();
        await checkNewNotification();
      }

  }

  _fetchProductsByCategory(String categoryId) async {
    products.clear();
    setState(() {
      isLoadingDataFromFS = true;
    });
    products.clear();
    if (categoryId != '0') {
      FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get()
          .then((snapshot) {
        setState(() {
          isLoadingDataFromFS = false;
          products = snapshot.docs
              .map((doc) => Product(
                    id: doc.id,
                    name: doc['name'],
                    company: doc['company'],
                    desc: doc['desc'],
                    price: doc['price'],
                    productImg: doc['productImg'],
                    categoryId: doc['categoryId'],
                    stock: doc['stock'],
                    isFavourite: favoriteProductIds.contains(doc.id),
                  ))
              .toList();
        });
      }).catchError((error) {
        isLoadingDataFromFS = false;
        print("Error fetching products by category: $error");
      });
    } else {
      FirebaseFirestore.instance.collection('products').get().then((snapshot) {
        setState(() {
          isLoadingDataFromFS = false;
          products = snapshot.docs
              .map((doc) => Product(
                    id: doc.id,
                    name: doc['name'],
                    company: doc['company'],
                    desc: doc['desc'],
                    price: doc['price'],
                    productImg: doc['productImg'],
                    categoryId: doc['categoryId'],
                    stock: doc['stock'],
                    isFavourite: favoriteProductIds.contains(doc.id),
                  ))
              .toList();
        });
      }).catchError((error) {
        isLoadingDataFromFS = false;
        print("Error fetching all products: $error");
      });
    }
  }

  fetchfavouriteProducts() async {
    favoriteProductIds.clear();
    QuerySnapshot favSnapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userid)
        .get();
    favoriteProductIds =
        favSnapshot.docs.map((doc) => doc['productId'].toString()).toList();
    print('favorite $favoriteProductIds');
  }

  void _toggleFavorite(String productId, bool isFavorite) async {
    setState(() {
      products = products.map((product) {
        if (product.id == productId) {
          product.isFavourite = !(product.isFavourite ??
              false); // Update the favorite status locally
          print("is fav value ${product.isFavourite}");
        }
        return product;
      }).toList();
    });

    print('is fav in toggle method $isFavorite');
    CollectionReference favorites =
        FirebaseFirestore.instance.collection('favorites');

    try {
      if (isFavorite) {
        await favorites
            .where('userId', isEqualTo: userid)
            .where('productId', isEqualTo: productId)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        }).then((snapshot) {
          print('object deleted');
        });
      } else {
        // Add to favorites
        await favorites.doc().set({
          'userId': userid,
          'productId': productId,
          'timestamp': FieldValue.serverTimestamp(),
        }).then((snap) {
          print('object added');
        });
      }
      //  Fetch updated favorites list
      await fetchfavouriteProducts();

      // Trigger UI update after favorite status is updated
    } catch (e) {
      // Handle any errors that occur
      print('Error in toggling favorite status: $e');
    }
  }

  void addToCart(String userId, String productId, int quantity,num stock) async {
    CollectionReference cartCollection =
        FirebaseFirestore.instance.collection('cart');
    try {
      QuerySnapshot snapshot = await cartCollection
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        DocumentReference docRef = snapshot.docs.first.reference;
        await docRef.delete();
        showSnackBar('Item removed from cart!');
      } else {
        // If the product does not exist, add it to the cart
        if(stock > 0){
          await cartCollection.add({
            'userId': userId,
            'productId': productId,
            'quantity': quantity,
            'timestamp': FieldValue.serverTimestamp(), // Optional
          }).then((snapshot) {
            showSnackBar('Item added in the cart!');
          });
          print('Added product $productId to cart');
        }
        else
          {
            showSnackBar('This product is out of stock.');
          }
      }
      fetchCartItems();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blue,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
      ),
    );
  }

  fetchCartItems() async {
    cartItemIds.clear();
    QuerySnapshot favSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userid)
        .get();
    setState(() {
      cartItemIds =
          favSnapshot.docs.map((doc) => doc['productId'].toString()).toList();
      print('cart items $cartItemIds');
    });
  }

  Future<void> checkNewNotification() async {
    try {
      // Query to get all notifications where isRead is false for the given user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userid)
          .where('isRead', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No unread notifications found.');
        setState(() {
          isNewNotification = false;
        });
        return;
      }
      else
        {
          setState(() {
            isNewNotification = true;
          });
        }
    } catch (e) {
      print('Failed to mark notifications as read: $e');
    }
  }
  Future<void> checkNewNotificationforAdmin() async {
    try {
      // Query to get all notifications where isRead is false for the given user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('adminNotifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No unread notifications found.');
        setState(() {
          isNewNotificationOfAdmin = false;
        });
        return;
      }
      else
      {
        setState(() {
          isNewNotificationOfAdmin = true;
        });
      }
    } catch (e) {
      print('Failed to mark notifications as read: $e');
    }
  }
}
