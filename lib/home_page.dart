import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  var currentLocation;
  var coordinates;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  Future<void> _launchURL() async {
    final url = 'https://www.google.com/maps/dir///@$coordinates,15z';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _getLocation() async {
    var currentLocation;

    try {
      currentLocation = await Location().getLocation();
      coordinates =
      "${currentLocation.latitude.toString()} , ${currentLocation.longitude.toString()}";
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {}
      currentLocation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient's Condition"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              model.logout();
            },
            icon: Icon(Icons.all_out),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          child: Icon(Icons.send),
          onPressed: () => _launchURL()),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Report Patient\'s Condition',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            levelButton('HIGH'),
            levelButton('MEDIUM'),
            levelButton('LOW'),
            levelButton('ALERT'),
            SizedBox(
              height: 60.0,
            )
          ],
        ),
      ),
    );
  }

  Widget levelButton(
      String lev,
      ) {
    return GestureDetector(
      onTap: () {
        int x;
        if (lev == "ALERT"){
          x = 1;
          Provider.of<Auth>(context).store(lev, coordinates);
          _launchURL();}
        else {
          x = 0 ;
        Provider.of<Auth>(context).store(lev, coordinates);
        _launchURL();
      }},
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 15.0,
        ),
        child: Center(
          child: Text(
            lev,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}