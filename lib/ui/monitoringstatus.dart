import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kuis_webapi/ui/Pilihan_Pembayaran.dart';

import 'login.dart';
import 'bottomNav.dart'; // Pastikan untuk mengimpor file yang berisi BottomNav

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math';

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
    print(userId);
    print('Berhasil mendapatkan status');
    Map<String, dynamic> parsedJson = jsonDecode(response.body);
    String status = parsedJson['status']['status'];
    print(status);
    return status;
  } else {
    print('Gagal mendapatkan status');
    throw Exception('Failed to get status');
  }
}

Future<void> setStatusDiterima() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.post(
    Uri.parse('http://146.190.109.66:8000/set_status_penjual_terima/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print(userId);
    print('Berhasil mengatur status menjadi diterima');
  } else {
    print('Gagal mengatur status');
    throw Exception('Failed to set status');
  }
}

Future<void> setStatusDitolak() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

   final response = await http.delete(
      Uri.parse('http://146.190.109.66:8000/clear_whole_carts_by_userid/$userId'), 
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

  if (response.statusCode == 200) {
    print(userId);
    print('Berhasil mengatur status menjadi Ditolak');
  } else {
    print('Gagal menghapus cart');
    throw Exception('Failed to set status');
  }
}

Future<void> pembersiahanCart() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.post(
    Uri.parse('http://146.190.109.66:8000/pembayaran/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print(userId);
    print('Berhasil mengatur status menjadi harap bayar');
  } else {
    print('Gagal mengatur status');
    throw Exception('Failed to set status');
  }
}





class Monitoringstatus extends StatefulWidget {
  Monitoringstatus({Key? key}) : super(key: key);

  @override
  _MonitoringstatusState createState() => _MonitoringstatusState();
}

class _MonitoringstatusState extends State<Monitoringstatus> {
  Timer? _timer;

  @override
 void initState() {
  super.initState();
  print("test1");
  _timer = Timer.periodic(const Duration(seconds: 30), (Timer t) async {
    var rng = new Random();
    int randomNumber = rng.nextInt(2); // Membuat angka acak 0 atau 1
    print("test2");
    String status = await getStatus();
    print(status);
    // ignore: unrelated_type_equality_checks
    if ("sudah_bayar" == status) {
      print("test3");
      if (randomNumber == 0) {
        setStatusDiterima();
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Monitoringstatus()),
      );
      } else {
        setStatusDitolak();
        pembersiahanCart();
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Monitoringstatus()),
      );
      }
    }
  });
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}



  final Box _boxLogin = Hive.box("login");
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoring Page"),
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
      bottomNavigationBar: BottomNavigasiBar(inputan: 1),
      body: Center(
          child: FutureBuilder<String>(
        future: getStatus(), // fungsi yang Anda buat untuk mendapatkan status
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else {
              String status = snapshot.data ?? '';
              switch (status) {
                case 'belum_bayar':
                  return BelumBayar(context);
                case 'pesanan_diterima':
                  return diantar(context);
                // tambahkan kasus lainnya sesuai kebutuhan
                default:
                  return tunggu(context);
              }
            }
          }
        },
      )),
    );
  }

  // ignore: non_constant_identifier_names
  Widget BelumBayar(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  const Pilihan_Pembayaran(), // Kirimkan item ke NextPage
        ),
      );
      // Anda bisa menambahkan aksi yang diinginkan saat Container diklik di sini
    },
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white
      ),
      child: const Text("Belum Bayar"),
    ),
  );
}
Widget tunggu(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white
    ),
    child: const Text("pesanan sedang di cek"),
  );
}

Widget diantar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white
    ),
    child: const Text("pesanan diantar"),
  );
}
}
