
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practicetest/ChatScreen.dart';
import 'package:practicetest/model/messageModel.dart';
import 'package:practicetest/model/userModel.dart';
import 'package:practicetest/provider/authProvider.dart';
import 'package:practicetest/provider/chatProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final searchController = TextEditingController();

  var search;

  AuthProvider authProvider = AuthProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
  }

  /// user status

  FirebaseFirestore firestore  =FirebaseFirestore.instance;

  setStatus(String status)async{

    firestore.collection('users').doc(authProvider.user!.uid).update({
      "status": status
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
    ChatProvider chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: myDrawer(authProvider),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                )),
          )
        ],
        title: Text(
          "${authProvider.user?.displayName}",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 45,
              alignment: Alignment.center,
              child: TextFormField(
                keyboardType: TextInputType.name,
                controller: searchController,
                onChanged: (v){
                  setState(() {
                    search = v;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                    hintText: "Search User",
                    suffixIcon: InkWell(
                        onTap: () {
                          searchController.clear();
                        },
                        child: Icon(Icons.clear)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "All Users",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder(
                future: chatProvider.fetchUsers(),
                builder: (c, AsyncSnapshot<dynamic> snapshot) {
                  // if(snapshot.connectionState == ConnectionState.waiting){
                  //   return Center(child: CircularProgressIndicator(),);
                  // }
                  if (snapshot.hasError) {
                    return Text('Error ${snapshot.error}');
                  }

                  /// show all data here

                  return  ListView.builder(
                      itemCount: chatProvider.userList.length,
                      itemBuilder: (c, i) {
                      String? newId =  authProvider.user?.uid.toString();

                        if(chatProvider.userList[i].id == newId){
                          return Container();
                        }
                        else {
                          if(search == "" || search == null){
                            return  ListTile(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(model: chatProvider.userList[i],)));
                              },
                              subtitle: StreamBuilder(
                                stream: chatProvider.getLastMessages(authProvider.user!.uid.toString(), chatProvider.userList[i].id.toString()),
                                builder: (c,snapshot){
                                  final data = snapshot.data?.docs;
                                 // Message message =
                                  if(data != null) {
                                    if (data.length == 0 ||
                                        data.isEmpty) {
                                      return SizedBox();
                                    }
                                    else {
                                      return Text("${data?[0]['message']}");
                                    }
                                  }
                                  else{
                                    return SizedBox();
                                  }
                                },
                              ),
                              trailing:  StreamBuilder<DocumentSnapshot>(
                                stream: firestore.collection('users').doc(chatProvider.userList[i].id).snapshots(),
                                builder: (c,snapshot){
                                  if(snapshot.data != null) {
                                    if(snapshot.data!['status'] == "Online"){
                                      return Icon(Icons.circle,size: 10,color: Colors.green,);
                                    }
                                  }
                                  else{
                                    return SizedBox();
                                  }
                                  return SizedBox();
                                },
                              ),
                              leading: chatProvider.userList[i].photo == null ||
                                  chatProvider.userList[i].photo == ""
                                  ? CircleAvatar(
                                child: Icon(Icons.person),
                              )
                                  : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "${chatProvider.userList[i].photo}"),
                              ),
                              title: Text("${chatProvider.userList[i].name}"),
                            );
                          }
                          else {
                            if (chatProvider.userList[i].name.toString().toLowerCase()
                                .contains('${search}'.toLowerCase())) {
                              return ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(model: chatProvider.userList[i],)));
                                },

                                leading: chatProvider.userList[i].photo ==
                                    null ||
                                    chatProvider.userList[i].photo == ""
                                    ? CircleAvatar(
                                  child: Icon(Icons.person),
                                )
                                    : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "${chatProvider.userList[i].photo}"),
                                ),
                                title: Text("${chatProvider.userList[i].name}"),
                              );
                            }
                            else {
                              return Container();
                            }
                          }
                        }
                      });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// drawer widget
  Widget myDrawer(AuthProvider authProvider) {
    return Drawer(
      elevation: 10,
      backgroundColor: Color(0xffF9F9F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        child: Column(
          children: [
            authProvider.user?.photoURL == ""
                ? CircleAvatar(
                    child: Icon(Icons.person),
                    backgroundColor: Colors.grey,
                    radius: 35,
                  )
                : CircleAvatar(
                    backgroundImage:
                        NetworkImage("${authProvider.user?.photoURL}"),
                    radius: 35,
                  ),
            SizedBox(
              height: 10,
            ),
            Text(
              "${authProvider.user?.displayName}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              "${authProvider.user?.email}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 15,
            ),
            Divider(),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text("Home"),
              leading: Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: () {
                authProvider.signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
