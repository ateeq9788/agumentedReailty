import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/material.dart';

Widget ProductWidget(String name,String company,String price){
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0), // Circular corner radius
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Shadow color
            blurRadius: 5.0, // Blur radius for the shadow
            offset: Offset(1, 2), // Shadow position
          ),
        ],
      ),
      child: Row(children: [
        Image.asset('assets/images/testImg.png',height: 50,width: 50,),
        SizedBox(width: 10,),
        Flexible(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5,),
            Text('Name: $name',style: TextStyle(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,maxLines: 2,),
            SizedBox(height: 3,),
            Text('Company: $company'),
            SizedBox(height: 3,),
            Text('Price: $price',style: TextStyle(fontWeight: FontWeight.w500),),
            SizedBox(height: 5,)
          ],
        ),),
      ],),
    ),
  );
}