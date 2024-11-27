import 'package:flutter/material.dart';
import 'package:agumented_reality_shopping_store/Widgets/TextFieldCustomWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Constants.dart' as Constantss;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Constants.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Category.dart';
import 'package:agumented_reality_shopping_store/CommonClasses/Product.dart';


class Addproductonstorescreen extends StatefulWidget {
  final Product? product;
  final bool? isEdit;
  const Addproductonstorescreen({super.key,this.product,this.isEdit});

  @override
  State<Addproductonstorescreen> createState() => _AddproductonstorescreenState();
}

class _AddproductonstorescreenState extends State<Addproductonstorescreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  File? file;
  File? fileWithoutbg;
  final String _removeBgApiKey = 'trY68CeD9eQpJ8Wf7Ry7z5vE';
  Category? selectedCategory;
  bool isloading = false;


  @override
  void initState() {
    super.initState();

    // Check if the widget is in edit mode
    if (widget.isEdit == true && widget.product != null) {
      // Pre-fill the fields with product data
      nameController.text = widget.product?.name ?? '';
      companyController.text = widget.product?.company ?? '';
      descriptionController.text = widget.product?.desc ?? '';
      priceController.text = widget.product?.price.toString() ?? '';
      stockController.text = widget.product?.stock.toString() ?? '';
      selectedCategory = categories.firstWhere(
            (category) => category.id == widget.product?.categoryId,
      );
      loadNetworkImageAsFile(widget.product?.productImg ?? '');
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed from the widget tree
    nameController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product'),centerTitle: true,backgroundColor: Colors.blue,foregroundColor: Colors.white,),
      body: SafeArea(child: Container(
        padding: EdgeInsets.all(10),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10,),
                    const Text('Add Product',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 24),),
                    const SizedBox(height: 20,),
                    fileWithoutbg != null ? Container(height: 150,width: 200,
                      child: Image(image: FileImage(fileWithoutbg!)),) :
                    GestureDetector(
                      onTap: (){
                        selectedFile();
                      },
                      child:  Container(height: 150,width: 150,decoration:
                      BoxDecoration(border:
                      Border.all(color: Colors.black,width: 0.5),borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image,size: 25,),
                            Text('Select Image')
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0,),
                    Container(
                        padding:EdgeInsets.fromLTRB(10, 5, 20, 5) ,width: MediaQuery.of(context).size.width - 60,height: 60,decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0), // Circular corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26, // Shadow color
                          blurRadius: 5.0, // Blur radius for the shadow
                          offset: Offset(1, 2), // Shadow position
                        ),
                      ],
                    ),
                        child: Row(children: [
                          Icon(Icons.category,color: Colors.blue,),
                          SizedBox(width: 10,),
                          Expanded(child: DropdownButton<Category>(
                            isExpanded: true,
                            hint: Text("Choose a Category"),
                            value: selectedCategory,
                            onChanged: (Category? newValue) {
                              setState(() {
                                selectedCategory = newValue; // Save the selected category
                              });
                            },
                            items: categories.map((Category category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Row(
                                  children: [
                                    // Optionally show the category icon
                                    Image.asset(category.icon, width: 20, height: 20),
                                    SizedBox(width: 12),
                                    Text(category.title), // Display category title
                                  ],
                                ),
                              );
                            }).toList(),
                            dropdownColor: Colors.white,
                          ),)
                        ],)),
                    SizedBox(height: 16.0,),
                    buildTextField(controller: nameController, hintText: 'Title', icon: Icons.title),
                    const SizedBox(height: 16.0),
                    buildTextField(controller: companyController, hintText: "Company Name", icon: Icons.business),
                    const SizedBox(height: 16.0),
                    buildTextField(controller: descriptionController, hintText: 'Description', icon: Icons.description),
                    const SizedBox(height: 16.0),
                    buildTextField(controller: stockController, hintText: "Available Stock", icon: Icons.scale,keyboardType : TextInputType.number ),
                    const SizedBox(height: 24.0),
                    buildTextField(controller: priceController, hintText: "Price", icon: Icons.price_change,keyboardType : TextInputType.number ),
                    const SizedBox(height: 24.0),
                    Expanded(child: ElevatedButton(
                      onPressed: (){

                        if (fileWithoutbg == null){
                          validationAlert('Submission Error!', 'Please Select Product Image.');
                          return;
                        }
                        if (selectedCategory == null){
                          validationAlert('Submission Error!', 'Please Select Product Category.');
                          return;
                        }

                        if (nameController.text.isEmpty){
                          validationAlert('Submission Error!', 'Please Enter Product Name.');
                          return;
                        }
                        if (companyController.text.isEmpty){
                          validationAlert('Submission Error!', 'Please Enter Company Name.');
                          return;
                        }
                        if (descriptionController.text.isEmpty){
                          validationAlert('Submission Error!', 'Please Enter Description of Product.');
                          return;
                        }
                        if (stockController.text.isEmpty){
                          validationAlert('Submission Error!', 'Please Enter available stock of Product.');
                          return;
                        }
                        if (priceController.text.isEmpty){
                          validationAlert('Submission Error!', 'Please Enter Product Price.');
                          return;
                        }
                        else
                        {
                          if(widget.isEdit == true){
                            editProduct(nameController.text ?? "", companyController.text ?? '', descriptionController.text ?? '', double.parse(priceController.text ?? ''), selectedCategory?.id ?? '',double.parse(stockController.text ?? ''),);
                          }
                          else
                          {
                            addProduct(nameController.text ?? "", companyController.text ?? '', descriptionController.text ?? '', double.parse(priceController.text ?? ''), selectedCategory?.id ?? '',double.parse(stockController.text ?? ''),);
                          }
                        }
                      },
                      child: isloading ? Center(child: CircularProgressIndicator(color: Colors.white,),) : Text(widget.isEdit == true ? 'Edit Product' : 'Add Product'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
  addProduct(String name,String company,String desc,double price,String catId,double stock) async
  {
    setState(() {
      isloading = true;
    });
    String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name for the image
    Reference storageReference = FirebaseStorage.instance.ref().child('product_images/$fileName');

    UploadTask uploadTask = storageReference.putFile(fileWithoutbg!);
    TaskSnapshot taskSnapshot = await uploadTask;

    // 2. Get the download URL of the uploaded image
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('products').doc().set({
          'name': name,
          'company': company,
          'desc' : desc,
          'price' : price,
          'stock' : stock,
          'createdAt': FieldValue.serverTimestamp(),
          'productImg' : imageUrl,
          'categoryId' : catId,
        }).then((_){
          setState(() {
            isloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your product has been added successfully.'),
              duration: Duration(seconds: 3),  // Duration of the SnackBar
            ),
          );
        })
            .catchError((error) {
              setState(() {
                isloading = false;
              });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error!\n${error.toString()}'),
              duration: Duration(seconds: 3),  // Duration of the SnackBar
            ),
          );
        });
        nameController.clear();
        companyController.clear();
        descriptionController.clear();
        priceController.clear();
        stockController.clear();
        setState(() {
          selectedCategory = null;
          fileWithoutbg = null;
        });

  }
  editProduct(String name,String company,String desc,double price,String catId,double stock) async
  {
    setState(() {
      isloading = true;
    });
    String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name for the image
    Reference storageReference = FirebaseStorage.instance.ref().child('product_images/$fileName');

    UploadTask uploadTask = storageReference.putFile(fileWithoutbg!);
    TaskSnapshot taskSnapshot = await uploadTask;

    // 2. Get the download URL of the uploaded image
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('products').doc(widget.product?.id ?? '').update({
      'name': name,
      'company': company,
      'desc' : desc,
      'price' : price,
      'stock' : stock,
      'createdAt': FieldValue.serverTimestamp(),
      'productImg' : imageUrl,
      'categoryId' : catId,
    }).then((_){
      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your product has been updated successfully.'),
          duration: Duration(seconds: 3),  // Duration of the SnackBar
        ),
      );
    })
        .catchError((error) {
      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error!\n${error.toString()}'),
          duration: Duration(seconds: 3),  // Duration of the SnackBar
        ),
      );
    });
    nameController.clear();
    companyController.clear();
    descriptionController.clear();
    priceController.clear();
    stockController.clear();
    setState(() {
      selectedCategory = null;
      fileWithoutbg = null;
    });

  }
  void validationAlert(String title,String message){
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        )
    );
  }
  selectedFile() {
    showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Choose image source'),
        actions: [
          ElevatedButton(
            child: const Text('Camera'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          ElevatedButton(
            child: const Text('Gallery'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ).then((ImageSource? source) async {
      if (source == null) return;

      final pickedFile = await ImagePicker().pickImage(source: source,imageQuality: 25);
      if (pickedFile == null) return;

      setState(() {
        file = File(pickedFile.path);
      });
      _removeBackground(file!);
      //pickedFile;
    });
  }
  Future<void> loadNetworkImageAsFile(String imgUrl) async {
     //imageUrl = imgUrl; // Replace with your image URL
    try {
      File file = await downloadImageToFile(imgUrl);
      setState(() {
        fileWithoutbg = file; // Assign the file to your variable
      });
      print('Image saved to: ${file.path}');
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<File> downloadImageToFile(String imageUrl) async {
    try {
      // Fetch the image data
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();

        // Use a unique filename for each download (to avoid caching issues)
        final fileName = 'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '${tempDir.path}/$fileName';

        final file = File(filePath);

        // Delete the previous image if it exists to ensure we always get the latest one
        if (await file.exists()) {
          print('Deleting old image at: $filePath');
          await file.delete(); // Delete the old image file
        }

        // Write the new image to the file
        await file.writeAsBytes(response.bodyBytes);

        print('Image downloaded to: $filePath');

        return file;
      } else {
        throw Exception('Failed to download image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }


  Future<void> _removeBackground(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image_file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
        "size": "auto",
      });

      Response response = await Dio().post(
        "https://api.remove.bg/v1.0/removebg",
        data: formData,
        options: Options(
          headers: {"X-Api-Key": _removeBgApiKey},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          fileWithoutbg = File('${Directory.systemTemp.path}/$fileName-no-bg.png');
          fileWithoutbg?.writeAsBytesSync(response.data);
        });
      } else {
        print('Error: ${response.statusCode}, ${response.statusMessage}');
      }
    } catch (e) {
      print('Error removing background: $e');
    }
  }
}
