

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_webapi/models/cart.dart';


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
    Uri.parse('http://146.190.109.66:8000/carts/$userId'), // Ganti dengan URL API keranjang Anda
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('berhasil');
    List jsonResponse = json.decode(response.body);
    List<Cart> carts = jsonResponse.map((cart) => Cart.fromJsoncart(cart)).toList();

    return carts;
  } else {
    print('gagal');
    throw Exception('Failed to load carts');
  }
}


class CartPage extends StatelessWidget {
  CartPage({Key? key}) : super(key: key);

  final Box _boxLogin = Hive.box("login");

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
      bottomNavigationBar: BottomNavigasiBar(inputan: 2),
      body: FutureBuilder<List<Cart>>(
        future: fetchCarts(),
        builder: (BuildContext context, AsyncSnapshot<List<Cart>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cart = snapshot.data![index];
                return ListTile(
                  title: Text('Item ID: ${cart.itemId}'), // Ganti dengan nama item
                  subtitle: Text('Quantity: ${cart.quantity}'), // Ganti dengan deskripsi item
                  trailing: Text('User ID: ${cart.userId}'), // Ganti dengan harga item
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
    );
  }
}
