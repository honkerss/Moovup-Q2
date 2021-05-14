import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:map_launcher/map_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:moovup_question_2/model/people.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _getList();
  }

  List<People> _list = [];
  String _error;
  bool _isLoading = true;

  Future<void> _getList() async {
    setState(() {
      _isLoading = true;
      _list = [];
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      final List<dynamic> peopleList = json.decode(prefs.getString('list'));
      _buildList(peopleList);
    } else {
      final url =
          Uri.parse('https://next.json-generator.com/api/json/get/41P1_UhSI');
      http.get(url).then((response) {
        prefs.setString('list', response.body);
        final List<dynamic> peopleList = json.decode(response.body);
        _buildList(peopleList);
      }).onError((error, stackTrace) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      });
    }
  }

  void _buildList(List<dynamic> peopleList) {
    peopleList.forEach((element) {
      final People people = People(
        id: element['_id'],
        picture: element['picture'],
        name: element['name'],
        email: element['email'],
        location: element['location'],
      );
      _list.add(people);
    });
    setState(() {
      _error = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ListView')),
      body: CustomScrollView(
        slivers: [
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            _error == null && _list.isNotEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final name = _list[index].name;
                      final fullName = "${name['first']} ${name['last']}";
                      return ListTile(
                        leading: CircleAvatar(
                          child: Image.network(_list[index].picture),
                        ),
                        title: Text(fullName),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(child: Text(fullName)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(radius: 40.0),
                                      const SizedBox(height: 16),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Email: '),
                                          Expanded(
                                              child: Text(_list[index].email,
                                                  style: const TextStyle(
                                                      color: Colors.blue))),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                          onPressed: () async {
                                            final lat = _list[index]
                                                .location['latitude'];
                                            final long = _list[index]
                                                .location['longitude'];
                                            if (lat is double &&
                                                long is double) {
                                              // final availableMaps =
                                              //     await MapLauncher
                                              //         .installedMaps;
                                              // await availableMaps.first
                                              //     .showMarker(
                                              //   coords: Coords(lat, long),
                                              //   title: fullName,
                                              // );
                                              MapsLauncher.launchCoordinates(
                                                  lat, long, fullName);
                                            } else {
                                              final errorLocation = lat == null
                                                  ? 'This object does not have a latitude coordinate!'
                                                  : long == null
                                                      ? 'This object does not have a longitude coordinate!'
                                                      : 'This object does not have valid location coordinates!';
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content:
                                                          Text(errorLocation)));
                                            }
                                          },
                                          child: Text('View Location')),
                                    ],
                                  ),
                                );
                              });
                        },
                      );
                    }, childCount: _list.length),
                  )
                : SliverFillRemaining(
                    child: Center(
                      child: Text(_error != null ? _error : 'List is empty.'),
                    ),
                  ),
        ],
      ),
    );
  }
}
