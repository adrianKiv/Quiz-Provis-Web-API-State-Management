import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:kuis_webapi/models/item.dart';
import 'dart:convert';

import 'login.dart';
import 'bottomNav.dart'; // Pastikan untuk mengimpor file yang berisi BottomNav

Future<Uint8List> fetchItemImage(int itemId) async {
  final String? accessToken = Hive.box("login").get('accessToken');

  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.get(
    Uri.parse('http://146.190.109.66:8000/items_image/$itemId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load item image');
  }
}


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
    List<Item> items = jsonResponse.map((item) => Item.fromJson(item)).toList();

    // Untuk setiap item, panggil API gambar dan perbarui imageUrl
    for (var item in items) {
      final imageUrl = await fetchItemImage(item.id);
      print(imageUrl);
      item.imageUrl = imageUrl;
    }

    return items;
  } else {
    print('gagal');
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
      bottomNavigationBar: const BottomNavigasiBar(inputan: 0),
      body: Center(
        child: FutureBuilder<List<Item>>(
          future: fetchItems(), // Pastikan fetchItems() adalah fungsi yang mengembalikan Future<List<Item>>
          builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
            if (snapshot.hasData) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Mendapatkan ukuran layar
                  double screenWidth = MediaQuery.of(context).size.width;
                  double screenHeight = MediaQuery.of(context).size.height;
git
                  // Menentukan ukuran berdasarkan ukuran layar
                  int crossAxisCount = screenWidth > 600? 3 : 2; // Contoh penyesuaian
                  double avatarRadius = screenWidth > 600? 115 : 60; // Contoh penyesuaian

                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: MemoryImage(item.imageUrl),
                              radius: avatarRadius,
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              item.title,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            // Tampilkan detail lainnya tentang item di sini
                          ],
                        ),
                      );
                    },
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
