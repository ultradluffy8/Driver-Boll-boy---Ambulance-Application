import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'http_exception.dart';

enum AuthMode { Login, SignUp }

class AuthenticationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthenticationPage();
  }
}

class _AuthenticationPage extends State<AuthenticationPage> {
  var _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  final Map<String, dynamic> _formData = {
    "email": null,
    "password": null,
    "username":null,
    "name":null,
  };

  DecorationImage _buildBackGroundImage() {
    return DecorationImage(
      fit: BoxFit.cover, image: AssetImage("assets/newAuthImage1.jpg"),);
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        } else return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password should atleast contain 6 characters';
        } return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match.';
        } else return null;
      },
    );
  }


  Widget _buildNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Name', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Enter a Name please';
        } else return null;
      },
      onSaved: (String value){
        _formData["name"] = value;
      },
    );
  }

  Widget _buildUserNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'UserName', filled: true, fillColor: Colors.white),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Enter a UserName please';
        } else return null;
      },
      onSaved: (String value) {_formData["username"] = value;},
    );
  }



  Widget _buildSubmitButton() {
    return RaisedButton(
        color: Colors.black87,
        child: Text(
          _authMode == AuthMode.Login ? "LOGIN" : "SIGNUP",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _submitForm();
        });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An error Occured!"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {

      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_formData["email"], _formData["password"]);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_formData["name"],_formData["username"],_formData["email"], _formData["password"],);
      }

    } on HttpException catch (error) {
      var errorMessage = "authentication Failed!";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "This email address is already in use!";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This is not a valid email!";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "This password is too weak!";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "This Email does not exist!";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid Password!";
      }
      _showErrorDialog(errorMessage);

    } catch (error) {
      print("asdfg111111111222");
      var errorMessage = "Could not authenticate you! Try again later";
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });


  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: _buildBackGroundImage(),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 110),
                  alignment: Alignment.center,
//                  child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.asset("assets/Logo1.png",height: 220,width: 220,),)
                    child: Text(
                      "Ambule",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 50),
                    ),
                ),
                SizedBox(
                  height: 30,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                  child: _buildNameTextField(),
                  width: deviceWidth * 0.85,
                )
                    : Container(),
                SizedBox(
                  height: 15,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                  child: _buildUserNameTextField(),
                  width: deviceWidth * 0.85,
                )
                    : Container(),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: _buildEmailTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: _buildPasswordTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                  child: _buildPasswordConfirmTextField(),
                  width: deviceWidth * 0.85,
                )
                    : Container(),
                SizedBox(
                  height: 25,
                ),
                _isLoading == true
                    ? CircularProgressIndicator()
                    : Container(
                  child: _buildSubmitButton(),
                  width: 200,
                ),
                SizedBox(
                  height: 30,
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      if (_authMode == AuthMode.Login) {
                        _authMode = AuthMode.SignUp;
                      } else {
                        _authMode = AuthMode.Login;
                      }
                    });
                  },
                  child: Text(_authMode == AuthMode.Login
                      ? "Not a user?  SignUp"
                      : "Login",style: TextStyle(color: Colors.black87),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
