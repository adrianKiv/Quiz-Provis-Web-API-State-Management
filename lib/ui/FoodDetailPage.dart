import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kuis_webapi/models/item.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_webapi/ui/home.dart';

Future<String> getStatus() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.get(
    Uri.parse('http://146.190.109.66:8000/get_status/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> parsedJson = jsonDecode(response.body);
    String status = parsedJson['status']['status'];
    return status;
  } else {
    throw Exception('Failed to get status');
  }
}

Future<void> setStatusHarapBayar() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.post(
    Uri.parse('http://146.190.109.66:8000/set_status_harap_bayar/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('Berhasil mengatur status menjadi harap bayar');
  } else {
    throw Exception('Failed to set status');
  }
}


Future<String> addToCart(Item item) async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');

  if (accessToken == null || userId == null) {
    throw Exception('No access token or user ID found');
  }

  String status = await getStatus();
  if(status != "pesanaan_diantar"){

    final response = await http.post(
      Uri.parse('http://146.190.109.66:8000/carts/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item_id': item.id,
        'user_id': userId,
        'quantity': 1, // Ganti dengan kuantitas yang diinginkan
      }),
    );

    if (response.statusCode == 200) {
      setStatusHarapBayar();
      return 'Berhasil menambahkan item ke keranjang';
    } else {
      throw Exception('Gagal menambahkan item ke keranjang');
    }
  }else{
    
    throw Exception('Gagal menambahkan item ke keranjang');
  }
}



class FoodDetailPage extends StatelessWidget {
  final Item item;

  const FoodDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
              ),
              child: Image.memory(item.imageUrl)
              ),
            const SizedBox(height: 8.0),
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Harga: Rp${item.price}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await addToCart(item);
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  } catch (e) {
                    print(e); // Tampilkan pesan kesalahan
                  }
                },
                child: const Text('Tambahkan ke Keranjang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
