import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja/data/cart_product.dart';
import 'package:loja/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  bool isLoading = false;

  UserModel user;

  List<CartProduct> products = [];

  String couponCode;
  int discountPercenage = 0;

  CartModel(this.user){
   if(user.isLoggedIn()){
     _loadCartItem();
   }
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);

    Firestore.instance.collection("users").document(user.firebaseUser.uid)
      .collection("cart").add(cartProduct.toMap()).then((doc) {
       cartProduct.cid = doc.documentID;
    });
  }

  void removeCartItem(CartProduct cartProduct){
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(cartProduct.cid).delete();

    products.remove(cartProduct);

    notifyListeners();
  }

  void decProduct(CartProduct cartproduct){
    cartproduct.quantity--;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
    .document(cartproduct.cid).updateData(cartproduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartproduct){
    cartproduct.quantity++;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .document(cartproduct.cid).updateData(cartproduct.toMap());

    notifyListeners();
  }

  void setCoupon(String couponCode, int discoountPercentage) {
    this.couponCode = couponCode;
    this.discountPercenage = discoountPercentage;
  }

  void updatePrices(){
    notifyListeners();
  }

  double getProductsPrice(){
    double price = 0.0;
    for(CartProduct c in  products){
      if(c.productData != null)
        price += c.quantity * c.productData.price;
    }
    return price;
  }

  double getDiscount(){
    return getProductsPrice() * discountPercenage / 100;
  }

  double getShipPrice(){
    return 9.99;
  }
  void _loadCartItem() async{
    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .getDocuments();

    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }

}