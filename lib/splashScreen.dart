import 'package:flutter/material.dart';
import 'package:practicetest/authSection/login.dart';
import 'package:practicetest/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 300),(){
      return checkUser();
    });
  }

  checkUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userEmail = pref.getString('userEmail');
    print("checking email ${userEmail}");
    if(userEmail == ""|| userEmail == null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
    }
    else{
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(child: Text("Splash Screen"),),
      ),
    );
  }
}
