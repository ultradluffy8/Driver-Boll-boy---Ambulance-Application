import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'http_exception.dart';
//import 'user_model.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  String _userEmail;

  //getters

  bool get isAuthenticated {
    return token != null;
  }

  String get userEmail {
    return _userEmail;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  //END OF GETTERS//

  Future<void> signUp(
      String name, String username, String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyD0yBQWm7r4kp1wPjEHHggtIG5vZqD3n3Q";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {"email": email, "password": password, "returnSecureToken": true},
        ),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData["error"]["message"]);
      }

      _userEmail = responseData["email"];

      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userAuthData = json.encode(
        {
          "email": _userEmail,
          "token": _token,
          "userId": _userId,
          "expiryDate": _expiryDate.toIso8601String(),
        },
      );
      prefs.setString("userAuthData", userAuthData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyD0yBQWm7r4kp1wPjEHHggtIG5vZqD3n3Q ";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {"email": email, "password": password, "returnSecureToken": true},
        ),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData["error"]["message"]);
      }

      _userEmail = responseData["email"];
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );

      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userAuthData = json.encode(
        {
          "email": _userEmail,
          "token": _token,
          "userId": _userId,
          "expiryDate": _expiryDate.toIso8601String(),
        },
      );
      prefs.setString("userAuthData", userAuthData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userAuthData")) {
      return false;
    }

    final extractedUserAuthData =
    json.decode(prefs.getString("userAuthData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserAuthData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _userEmail = extractedUserAuthData["email"];
    _token = extractedUserAuthData["token"];
    _userId = extractedUserAuthData["userId"];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _expiryDate = null;
    _userId = null;
    _token = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

//    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticationPage()), (Route<dynamic> route) => false);
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }

  Future<void> store(String request,String coordinates ) async {
    int x ;
    String st1 ;
    if (x == 0){
    st1 = "https://ambule-87e50.firebaseio.com/requests.json" ;}
    else {
    st1 = "https://technoxians.firebaseio.com/requests.json";
    }
    final url = st1;

    final response = await http.post(url,body: json.encode({
      "request": request,
      "coordinates": coordinates,
    }));

    final responseData = json.decode(response.body);

    print(responseData);
  }


}
