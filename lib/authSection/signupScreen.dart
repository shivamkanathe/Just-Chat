import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {


  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  /// form key
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Sign up",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
              TextFormField(controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v){
                  if(!v!.contains('@')){
                    return "Enter a valid email";
                  }
                  if(v.isEmpty){
                    return "Email is required";
                  }
                },
                decoration: InputDecoration(
                  hintText: "Enter email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              TextFormField(controller: passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                validator: (v){
                  if(v!.isEmpty){
                    return "Password is required";
                  }
                  if(v!.length <6){
                    return "Password must be greater than 6";
                  }
                },
                decoration: InputDecoration(
                  hintText: "Enter Password",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              TextFormField(controller: phoneController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (v){
                  if(v!.length < 10){
                    return "Enter a valid number";
                  }
                  if(v.isEmpty){
                    return "Phone is required";
                  }
                },
                decoration: InputDecoration(
                  hintText: "Enter Phone number",
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              MaterialButton(
                height: 45,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                color: Colors.blue,
                minWidth: MediaQuery.of(context).size.width/2,
                onPressed: (){
                  if(_formKey.currentState!.validate()){

                  }
                  else{
                    Get.snackbar("All fields are required", "Please enter correct detail",snackPosition: SnackPosition.BOTTOM);
                  }
                },
                child: Text("Login",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
              ) ,
              SizedBox(height: 20,),
            InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text("Already have an account? Login")),

            ],
          ),
        ),
      ),
    );
  }
}
