import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:kuis_webapi/models/item.dart';
import 'dart:convert';

import 'login.dart';
import 'bottomNav.dart'; // Pastikan untuk mengimpor file yang berisi BottomNav




Future<List<Item>> fetchItems() async {
  final String? accessToken = Hive.box("login").get('accessToken');

  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.get(
    Uri.parse('http://146.190.109.66:8000/items/?skip=0&limit=100'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('berhasil');
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Item.fromJson(item)).toList();
  } else {
    print('test');
    throw Exception('Failed to load items');
  }
}


class Home extends StatelessWidget {
  Home({super.key});

  final Box _boxLogin = Hive.box("login");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: IconButton(
                onPressed: () {
                  _boxLogin.clear();
                  _boxLogin.put("loginStatus", false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      bottomNavigationBar: BottomNavigasiBar(inputan: 0),
      body: Center(
        child: FutureBuilder<List<Item>>(
          future: fetchItems(),
          builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data![index].title),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
