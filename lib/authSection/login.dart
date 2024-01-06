import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:practicetest/authSection/signupScreen.dart';
import 'package:practicetest/provider/authProvider.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  /// animation controllers
  late AnimationController _controller;
  late Animation<double> _animation;


  /// form key
  final _formKey = GlobalKey<FormState>();

  int currentIndex = 1;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // Handle successful sign-in here
      GoogleSignInAccount? user = _googleSignIn.currentUser;
      print('User: ${user?.displayName}');
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Set the duration of the animation
    );

    _animation = Tween<double>(begin: 0, end: 200).animate(_controller);

    // Start the animation
    _controller.forward();
  }


  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text(
            //   "Login",
            //   style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 25,
            //       fontWeight: FontWeight.w600),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     MaterialButton(
            //       shape: RoundedRectangleBorder(
            //           side: BorderSide(
            //               color:
            //                   currentIndex == 1 ? Colors.blue : Colors.black),
            //           borderRadius: BorderRadius.circular(10)),
            //       onPressed: () {
            //         setState(() {
            //           currentIndex = 1;
            //         });
            //       },
            //       child: Text("Login with email"),
            //     ),
            //     MaterialButton(
            //       shape: RoundedRectangleBorder(
            //           side: BorderSide(
            //               color:
            //                   currentIndex == 2 ? Colors.blue : Colors.black),
            //           borderRadius: BorderRadius.circular(10)),
            //       onPressed: () {
            //         setState(() {
            //           currentIndex = 2;
            //         });
            //       },
            //       child: Text("Login with Phone"),
            //     )
            //   ],
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // currentIndex == 1
            //     ? Form(
            //         key: _formKey,
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             TextFormField(
            //               controller: emailController,
            //               keyboardType: TextInputType.emailAddress,
            //               validator: (v) {
            //                 if (!v!.contains('@')) {
            //                   return "Enter a valid email";
            //                 }
            //                 if (v.isEmpty) {
            //                   return "Email is required";
            //                 }
            //               },
            //               decoration: InputDecoration(
            //                 hintText: "Enter email",
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(10),
            //                 ),
            //               ),
            //             ),
            //             SizedBox(
            //               height: 15,
            //             ),
            //             TextFormField(
            //               controller: passwordController,
            //               keyboardType: TextInputType.text,
            //               obscureText: true,
            //               validator: (v) {
            //                 if (v!.isEmpty) {
            //                   return "Password is required";
            //                 }
            //               },
            //               decoration: InputDecoration(
            //                 hintText: "Enter Password",
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(10),
            //                 ),
            //               ),
            //             ),
            //             SizedBox(
            //               height: 20,
            //             ),
            //             MaterialButton(
            //               height: 45,
            //               shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(10)),
            //               color: Colors.blue,
            //               minWidth: MediaQuery.of(context).size.width / 2,
            //               onPressed: () {
            //                 if (_formKey.currentState!.validate()) {
            //                 } else {
            //                   Get.snackbar("All fields are required",
            //                       "Please enter correct detail",
            //                       snackPosition: SnackPosition.BOTTOM);
            //                 }
            //               },
            //               child: Text(
            //                 "Login",
            //                 style: TextStyle(
            //                     color: Colors.white,
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.bold),
            //               ),
            //             ),
            //           ],
            //         ),
            //       )
            //     : Form(
            //         key: _formKey,
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             TextFormField(
            //               controller: phoneController,
            //               keyboardType: TextInputType.number,
            //               maxLength: 10,
            //               validator: (v) {
            //                 if (v!.length < 10) {
            //                   return "Enter a valid number";
            //                 }
            //                 if (v.isEmpty) {
            //                   return "Phone is required";
            //                 }
            //               },
            //               decoration: InputDecoration(
            //                 hintText: "Enter Phone number",
            //                 counterText: "",
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(10),
            //                 ),
            //               ),
            //             ),
            //             SizedBox(
            //               height: 20,
            //             ),
            //             MaterialButton(
            //               height: 45,
            //               shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(10)),
            //               color: Colors.blue,
            //               minWidth: MediaQuery.of(context).size.width / 2,
            //               onPressed: () {
            //                 if (_formKey.currentState!.validate()) {
            //                 } else {
            //                   Get.snackbar("All fields are required",
            //                       "Please enter correct detail",
            //                       snackPosition: SnackPosition.BOTTOM);
            //                 }
            //               },
            //               child: Text(
            //                 "Login",
            //                 style: TextStyle(
            //                     color: Colors.white,
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.bold),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            // SizedBox(
            //   height: 10,
            // ),
            // InkWell(
            //     onTap: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => SignUpScreen()));
            //     },
            //     child: Text("Don't have an account? Signup")),
            // SizedBox(height: 15,),
            //
            // Row(
            //   children: [
            //     Expanded(child: Divider()),
            //     Text(" Or "),
            //     Expanded(child: Divider()),
            //   ],
            // ),
            // SizedBox(height: 20,),
              
            AnimatedBuilder(
              animation: _controller,
              builder: (c,child){
                return Container(
                  height: _animation.value,
                  width: _animation.value,
                  child: Image.asset("Images/messaging.png"),
                );
              },
            ),
            InkWell(
              onTap: (){
                authProvider.signInWithGoogle(context);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 100),
                height: 45,
                width: MediaQuery.of(context).size.width/1.5,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("Images/search.png",height: 25,width: 25,),
                    SizedBox(width: 10,),
                    Text("Sign In with Google",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w500),)
                  ],
                ),
              ),
            ),

            // SocialLoginButton(
            //   backgroundColor: Colors.black12,
            //   imageWidth: 25,
            //   textColor: Colors.white,
            //   width: MediaQuery.of(context).size.width/1.5,
            //   buttonType: SocialLoginButtonType.google,
            //   onPressed: () {
            //     authProvider.signInWithGoogle(context);
            //    // _handleSignIn();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
