import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'home_page.dart';
import 'auth_page.dart';
import 'auth_provider.dart';

main() {
  runApp(MyFoodApp());
}

class MyFoodApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyFoodApp();
  }
}

class _MyFoodApp extends State<MyFoodApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: auth.isAuthenticated
              ? HomePage()
              : FutureBuilder(
              future: auth.autoLogin(),
              builder: (context, authResult) =>
              authResult.connectionState == ConnectionState.waiting
                  ? Scaffold(body: Center(child: Text("Ambulance App"),),)
                  : AuthenticationPage()),
        ),
      ),
    );
  }
}
