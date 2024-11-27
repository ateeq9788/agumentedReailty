class Product {
  final String id;
  final String name;
  final String categoryId;
  final String productImg;
  final String desc;
  final num stock;
  final double price;
  final String company;
   bool? isFavourite;

  Product({required this.id, required this.name, required this.categoryId,required this.productImg,required this.desc,required this.price,required this.company, this.isFavourite,required this.stock});
}