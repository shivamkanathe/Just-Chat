import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  String? senderId,senderName,receiverId,message,type;
  Timestamp? timestamp;

  Message({
    this.timestamp,this.message,this.receiverId,this.senderId,this.senderName,this.type
});

  /// convert to map
  Map<String,dynamic> toMap(){
    return{
      'senderId':senderId,
      'senderName':senderName,
      'receiverId':receiverId,
      'message':message,
      'type':type,
      'timestamp':timestamp
    };
  }
}