import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:practicetest/authSection/login.dart';
import 'package:practicetest/homeScreen.dart';
import 'package:practicetest/model/userModel.dart';
import 'package:practicetest/widget/customDialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class AuthProvider extends ChangeNotifier{

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  User? _user;

  UserModel userModel = UserModel();

  User? get user => _user;

  AuthProvider(){
    getUserDetail();
  }


/// firebsae push notification function
  FirebaseMessaging fMessaging = FirebaseMessaging.instance;
    String fcmToken = '';
   Future<void> getFirebaseMessageingToken()async{
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t){
      if(t != null){
        userModel.token = t;
        fcmToken = t;
        print("push token here ${t}");
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

/// google signIn function
  Future signInWithGoogle(context) async {
     bool istapped = false;
    FirebaseAuth auth = FirebaseAuth.instance;
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
        FirebaseFirestore _firestore = FirebaseFirestore.instance;
        await getFirebaseMessageingToken();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken
      );
        istapped =  true;
      final UserCredential  userCredential = await auth.signInWithCredential(credential);

      _user = userCredential.user;
      showDialog(context: context, builder: (c){
        return AlertDialog(
          content: CustomDialog(),
        );
      });
      if(_user!.displayName == null || _user!.displayName == ""){
      }
      else {

        await _firestore.collection('users').doc(auth.currentUser!.uid).set({
          "name": _user!.displayName.toString(),
          "email": _user!.email.toString(),
          "status": "Online",
          "photo": _user!.photoURL.toString(),
          "uid": _user!.uid,
          "token": fcmToken,
        });

        print("new user here ${_user}");
        Provider.of<AuthProvider>(context,listen: false).setUser(_user);
        pref.setString('userName', _user!.displayName.toString());
        pref.setString('userEmail', _user!.email.toString());
        Get.snackbar("Successful", "Logged in successfully",
            snackPosition: SnackPosition.BOTTOM);
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => HomeScreen()), (
            route) => false);
        notifyListeners();
      }
    } catch (error) {
      Get.snackbar("Something went wrong", "Please try again letter",snackPosition: SnackPosition.BOTTOM);
      print(error);
    }
  }



  /// set user
  void setUser(User? newUser){
    _user = newUser;
    notifyListeners();
  }

  void getUserDetail(){
  _user = FirebaseAuth.instance.currentUser;
  getFirebaseMessageingToken();
    notifyListeners();
  }

  setUserDetail(context){
  }

  /// google signOut function
  Future<void> signOut(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await _googleSignIn.signOut();
    _user = null;
    pref.setString('userName', '');
    pref.setString('userEmail', '');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginPage()), (route) => false);
    notifyListeners();
  }
}