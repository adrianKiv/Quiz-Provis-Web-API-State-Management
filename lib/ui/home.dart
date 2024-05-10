import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:kuis_webapi/models/item.dart';
import 'package:kuis_webapi/ui/FoodDetailPage.dart';
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
    List jsonResponse = json.decode(response.body);
    List<Item> items = jsonResponse.map((item) => Item.fromJson(item)).toList();

    // Untuk setiap item, panggil API gambar dan perbarui imageUrl
    for (var item in items) {
      final imageUrl = await fetchItemImage(item.id);
      
      item.imageUrl = imageUrl;
    }

    return items;
  } else {
    throw Exception('Failed to load items');
  }
}




class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Box _boxLogin = Hive.box("login");
  final TextEditingController _searchController = TextEditingController();
  List<Item> _items = []; // This should be your original list of items
  List<Item> _filteredItems = []; // This will be the list of items after search

  @override
  void initState() {
    super.initState();
    fetchItems().then((items) {
      setState(() {
        globalItems = items;
        _items = items;
        _filteredItems = items;
      });
    });

    _searchController.addListener(() {
      setState(() {
        String searchText = _searchController.text;
        _filteredItems = _items.where((item) {
          return item.title.toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, size: 30),
            border: OutlineInputBorder(
              
              borderSide: const BorderSide(width: 2.0),
            ),
          ),
        ),
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
          future: fetchItems(),
          builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
            if (snapshot.hasData) {
              List<Item> items = _filteredItems; // Use the filtered items here

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  int crossAxisCount = screenWidth > 600? 3 : 2;
                  double avatarRadius = screenWidth > 600? 115 : 60;

                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailPage(item: item),
                            ),
                          );
                        },
                        child: Card(
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
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
