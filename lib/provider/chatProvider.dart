import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practicetest/model/messageModel.dart';
import 'package:practicetest/model/userModel.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier{

  final FirebaseFirestore _firestore  = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<UserModel> _userList = [];

  List<UserModel> get userList => _userList;


/// get all users
  Future<void> fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      _userList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return UserModel(id: doc.id, name: data['name'], email: data['email'],status: data['status'],photo: data['photo'],token: data['token']);
      }).toList();

      notifyListeners();
    } catch (error) {
      print('Error fetching users: $error');
      // Handle the error as needed
    }
  }

  /// send message

Future<void> sendMessage(String receiverName,String token,String receiverId,String message)async{
    final String? currentUserId = auth.currentUser?.uid.toString();
    final String? currentUserName = auth.currentUser?.displayName.toString();
    final Timestamp timestamp = Timestamp.now();

    // create new message
  Message newMess = Message(senderId: currentUserId,senderName: currentUserName,receiverId: receiverId,timestamp: timestamp,message: message,type: 'text');

  // create chat room id from current user id and receiver id (sorted to ensure uniqueness)

  List<String> ids = [currentUserId.toString(),receiverId];
  ids.sort(); // sort ids to ensure chat room id is always same
  String chatRoomId  = ids.join("_"); // combine both id to single string to use as chatRoomId

  //add message to database
  await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMess.toMap()).then((value) => sendPushNotification(receiverName, token,message));
}



  /// send push notification

  Future<void> sendPushNotification(String name,String token, String msg)async{
    try{
      final body = {
        "to":"${token}",
        "notification":{
          "title":"${name}",
          "body":"${msg}",
          "android_channel_id":"chats"
        },
        "data": {
          "some_data" : "User ID: ${auth.currentUser?.uid}",
        },
      };
      var response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:'key=AAAAcIlBKO0:APA91bF8ArJ0YOn9J1HPE4KdiCwfSHeBbaqvMh0BAEeH3Z341nn4-Wimy-rH3PbnMWeYVSSCShloi3rf_KXAi6tLMJe_jfkjy4wgiPsGn8QK9xMqA-wiO0cNAUAHZb5InWe4LFaoiPuK'

          },
          body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    catch(e){
      print("Error is ${e}");
    }
  }



  /// add images
Future addImages(String receiverName, String token, String receiverId)async{
  String fileName = Uuid().v1();
  int status = 1;
  final String? currentUserId = auth.currentUser?.uid.toString();
  final String? currentUserName = auth.currentUser?.displayName.toString();
  final Timestamp timestamp = Timestamp.now();

  // create new message
  Message newMess = Message(senderId: currentUserId,senderName: currentUserName,receiverId: receiverId,timestamp: timestamp,message: "",type: 'img');

  // create chat room id from current user id and receiver id (sorted to ensure uniqueness)

  List<String> ids = [currentUserId.toString(),receiverId];
  ids.sort(); // sort ids to ensure chat room id is always same
  String chatRoomId  = ids.join("_"); // combine both id to single string to use as chatRoomId

  _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(fileName).set(newMess.toMap());

  var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
  var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
    print("checking image error ${error} and ${fileName}");
    _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(fileName)
        .delete();
    status = 0;
  });

  if (status == 1) {
    String ImageUrl = await uploadTask.ref.getDownloadURL();

   await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(fileName)
        .update({"message": ImageUrl}).then((value) => sendPushNotification(receiverName, token, ''));

  }

  //add message to database
  //await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMess.toMap());
notifyListeners();
  }

  /// get images
  File? imageFile;

  Future getImage(String receiverId,token,receiverName) async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        addImages(receiverId,token,receiverName);
      }
    });
    notifyListeners();
  }

/// get messages

Stream<QuerySnapshot> getMessages(String userid,String otheruserId){
    //construct chat room id from usre ids
  List<String>  ids = [userid,otheruserId];
  ids.sort();
  String chatRoomId  =ids.join("_");
  return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp',descending: true).snapshots();
}

/// get only last message

  Stream<QuerySnapshot> getLastMessages(String userid,String otheruserId){
    //construct chat room id from usre ids
    List<String>  ids = [userid,otheruserId];
    ids.sort();
    String chatRoomId  =ids.join("_");
    return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp',descending: true).limit(1).snapshots();
  }
}