import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_webapi/models/cart.dart';

import 'package:kuis_webapi/ui/Pilihan_Pembayaran.dart';

import 'dart:convert';

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
    List jsonResponse = json.decode(response.body);
    List<Cart> carts =
        jsonResponse.map((cart) => Cart.fromJsoncart(cart)).toList();

    return carts;
  } else {
    throw Exception('Failed to load carts');
  }
}

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

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
      // Navigate to new page
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    } else {
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
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigasiBar(inputan: 2),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Cart>>(
              future: fetchCarts(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Cart>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final cart = snapshot.data![index];
                      return Card(
                        elevation: 5,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.memory(cart.toItem().imageUrl,
                                  width: 50, height: 50),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Nama: ${cart.toItem().title}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('Harga: ${cart.toItem().price}',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () async {
                                await deleteCart(context, cart.id);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
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
            padding: const EdgeInsets.all(16.0),
            color: Colors.lightBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<List<Cart>>(
                  future: fetchCarts(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Cart>> snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final totalHarga = snapshot.data!
                          .map((cart) => cart.toItem().price)
                          .reduce((value, element) => value + element);
                      return Text(
                        'Total Harga: $totalHarga',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    } else {
                      return const Text(
                        'Tidak ada item dalam keranjang',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    }

                  // Mengembalikan widget kosong jika tidak ada data
                  },
                ),
                // Tambahkan tombol checkout di sini
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Pilihan_Pembayaran(), // Kirimkan item ke NextPage
                      ),
                    );
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
