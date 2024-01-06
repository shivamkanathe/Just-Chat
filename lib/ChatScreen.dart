import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practicetest/model/userModel.dart';
import 'package:practicetest/provider/authProvider.dart';
import 'package:practicetest/provider/chatProvider.dart';
import 'package:practicetest/viewImage.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  UserModel? model;
  ChatScreen({this.model});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {

  final messageController  = TextEditingController();

  final ChatProvider chatProvider = ChatProvider();


  void sendMessage()async{
  if(messageController.text.isNotEmpty){
    await chatProvider.sendMessage(widget.model!.name.toString(), widget.model!.token.toString(), widget.model!.id.toString(), messageController.text);

    messageController.clear();
  }
  }

  void sendImage()async{
    await chatProvider.getImage(widget.model!.id.toString(),widget.model!.token.toString(),widget.model!.name.toString());
  }

  AuthProvider authProvider = AuthProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
  }


  FirebaseFirestore firestore  =FirebaseFirestore.instance;
  /// user status

  setStatus(String status)async{
    print("checking token here ${authProvider.userModel.token}");
    firestore.collection('users').doc(authProvider.user!.uid).update({
      "status": status,
      "token": authProvider.userModel.token,
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus('Online');
    } else {
      setStatus('Offline');
      // offline
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        automaticallyImplyLeading: false,
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
            ),
            SizedBox(width: 5,),
            CircleAvatar(radius: 18,backgroundImage: NetworkImage('${widget.model?.photo}'),)
          ],
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection('users').doc(widget.model?.id).snapshots(),
          builder: (c,snapshot){
            if(snapshot.data != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${snapshot.data!['name']}",
                    style: TextStyle(color: Colors.white, fontSize: 15),),
                  Text("${snapshot.data!['status']}",
                    style: TextStyle(color: Colors.white, fontSize: 12),),
                ],
              );
            }
            else{
              return Container();
            }
          },
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // messages
           Expanded(
             child: _buildMessageList(),
           ),
            // message input
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _buildMessageInput(),
            ),
          ],
        ),
      ),
    );
  }


  // build message input
  Widget _buildMessageInput(){
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: messageController,
            decoration: InputDecoration(
              suffixIcon: InkWell(
                  onTap: sendImage,
                  child: Icon(Icons.photo)),
                hintText: "Enter a message",
                border: OutlineInputBorder(
                  borderRadius:BorderRadius.circular(11),
                )
            ),
          ),
        ),
        SizedBox(width: 5,),
        InkWell(
            onTap: sendMessage,
            child: CircleAvatar(child: Center(child: Icon(Icons.send,color: Colors.white,)),backgroundColor: Colors.deepPurple,))

      ],
    );
  }

  // build Message list

  Widget _buildMessageList(){
    AuthProvider auth = Provider.of<AuthProvider>(context);
    return StreamBuilder(stream: chatProvider.getMessages(widget.model!.id.toString(),auth.user!.uid.toString() ), builder: (c,snapshot){
      if(snapshot.hasError){
        return Text("Error ${snapshot.error}");
      }
      if(snapshot.connectionState == ConnectionState.waiting){
        return Text("Loading..");
      }
      if(snapshot.data != null){
        print("working ddg ${snapshot.data!.docs.length}");
        return ListView.builder(
          reverse:true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder:(c,i){
              var map =snapshot.data!.docs[i].data();
              print("new answer ${snapshot.data!.docs[i]}");
          return _buildMessageItem(snapshot.data!.docs[i]);
        });
        //   ListView(
        //   children: snapshot.data!.docs.map((document){
        //     print("nnnnnn ${document}");
        //     return  _buildMessageItem(document);
        //   }).toList(),
        // );
      }
      return Container();
    });
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    final size = MediaQuery.of(context).size;

    AuthProvider auth = Provider.of<AuthProvider>(context);
    Map<String,dynamic> data = document.data() as Map<String,dynamic>;

    // align messages to right if sender or else to left
    var alignment = (data['senderId'] == auth.user?.uid.toString()) ? Alignment.centerRight: Alignment.centerLeft;
    return Container(
      padding: EdgeInsets.only(top: 8,bottom: 8),
      child: Align(
        alignment: alignment,
        child: data['type'] == "img" ? InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(image: "${data['message']}",)));
          },
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                  height: 200,
                width: 200,
                child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Opacity(
                    opacity: 1,
                    child: CachedNetworkImage(
                    fit: BoxFit.cover,
                      width: 200,
                      imageUrl: "${data['message']}",

                      placeholder: (context, url) => Container(
                          height: 30,
                          width: 25,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
               // Image.network("${data['message']}",fit: BoxFit.fill,width: 200,),
              ),
              // Container(
              //     alignment: Alignment.center,
              //     height: 200,
              //     width: 200,
              //     child: Icon(Icons.download_rounded,color: Colors.white,size: 30,))
            ],
          ),
        ) :
        Column(
          children: [
            Container(
              // alignment: alignment,
              // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width/1.8),
              //
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: data['senderId'] == auth.user?.uid.toString() ? BorderRadius.only(topLeft: Radius.circular(9),topRight: Radius.circular(9),bottomLeft: Radius.circular(9),bottomRight: Radius.circular(0)) : BorderRadius.only(topLeft: Radius.circular(9),topRight: Radius.circular(9),bottomLeft: Radius.circular(0),bottomRight: Radius.circular(9)),
                  color: (data['senderId'] == auth.user?.uid.toString())  ?
                  Colors.deepPurple : Colors.blueGrey
              ),
              child: Text(data['message'],style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
