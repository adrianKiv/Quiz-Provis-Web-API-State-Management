import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_webapi/models/cart.dart';
import 'package:kuis_webapi/models/item.dart';

import 'dart:convert';
import 'login.dart';
import 'bottomNav.dart'; // Pastikan untuk mengimpor file yang berisi BottomNav



Future<List<Cart>> fetchCarts() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.get(
    Uri.parse(
        'http://146.190.109.66:8000/carts/$userId'), // Ganti dengan URL API keranjang Anda
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('berhasil');
    List jsonResponse = json.decode(response.body);
    List<Cart> carts =
        jsonResponse.map((cart) => Cart.fromJsoncart(cart)).toList();

    return carts;
  } else {
    print('gagal');
    throw Exception('Failed to load carts');
  }
}

class CartPage extends StatelessWidget {
  CartPage({Key? key}) : super(key: key);

  final Box _boxLogin = Hive.box("login");

  
 Future<void> deleteCart(BuildContext context, int cartId) async {
    final String? accessToken = Hive.box("login").get('accessToken');
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.delete(
      Uri.parse('http://146.190.109.66:8000/carts/$cartId'), 
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('Delete successful');
      // Navigate to new page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CartPage()),
      );
    } else {
      print('Delete failed');
      throw Exception('Failed to delete cart');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart Page"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      bottomNavigationBar: const BottomNavigasiBar(inputan: 2),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Cart>>(
              future: fetchCarts(),
              builder: (BuildContext context, AsyncSnapshot<List<Cart>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final cart = snapshot.data![index];
                      return ListTile(
                        leading: Image.memory(cart.toItem().imageUrl),
                        title: Text('Nama: ${cart.toItem().title}'),
                        subtitle: Text('Harga: ${cart.toItem().price}'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await deleteCart(context, cart.id);
                          },
                          child: const Icon(Icons.delete),
                        ),
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
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<List<Cart>>(
                  future: fetchCarts(),
                  builder: (BuildContext context, AsyncSnapshot<List<Cart>> snapshot) {
                    if (snapshot.hasData) {
                      final totalHarga = snapshot.data!
                          .map((cart) => cart.toItem().price)
                          .reduce((value, element) => value + element);
                      return Text(
                        'Total Harga: $totalHarga',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    return const SizedBox(); // Mengembalikan widget kosong jika tidak ada data
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan logika checkout di sini
                  },
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
