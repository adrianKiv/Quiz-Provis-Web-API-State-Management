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
    Map<String, dynamic> parsedJson = jsonDecode(response.body);
    String status = parsedJson['status']['status'];
    return status;
  } else {
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
    print('Berhasil mengatur status menjadi diterima');
  } else {
    throw Exception('Failed to set status');
  }
}

Future<void> setStatusDiantar() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.post(
    Uri.parse('http://146.190.109.66:8000/set_status_diantar/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('Berhasil mengatur status menjadi diantar');
  } else {

    throw Exception('Failed to set status');
  }
}

Future<void> setStatusSampai() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final response = await http.post(
    Uri.parse('http://146.190.109.66:8000/set_status_diterima/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    print('Berhasil mengatur status menjadi diterima');
  } else {
    throw Exception('Failed to set status');
  }
}

Future<void> setStatusDitolak() async {
  final String? accessToken = Hive.box("login").get('accessToken');
  final int? userId = Hive.box("login").get('userId');
  if (accessToken == null) {
    throw Exception('No access token found');
  }

   final response = await http.post(
      Uri.parse('http://146.190.109.66:8000/set_status_penjual_tolak/$userId'), 
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

  if (response.statusCode == 200) {
    print('Berhasil mengatur status menjadi Ditolak');
  } else {
    throw Exception('Failed to set status');
  }
}

Future<void> pembersiahanCart() async {
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
    print('Berhasil mengatur status menjadi harap bayar');
  } else {
    throw Exception('Failed to set status');
  }
}





class Monitoringstatus extends StatefulWidget {
  const Monitoringstatus({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MonitoringstatusState createState() => _MonitoringstatusState();
}

class _MonitoringstatusState extends State<Monitoringstatus> {
  Timer? _timer;

  @override
 void initState() {
  super.initState();
  
  _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) async {
    var rng = Random();
    int randomNumber = rng.nextInt(2); // Membuat angka acak 0 atau 1
    
    String status = await getStatus();
    
    // ignore: unrelated_type_equality_checks
    if ("sudah_bayar" == status) {
      if (randomNumber == 0) {
        await setStatusDiterima();
        await setStatusDiantar();
        Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const Monitoringstatus()),
      );
      } else {
        await setStatusDitolak();
        await pembersiahanCart();
        Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const Monitoringstatus()),
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
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigasiBar(inputan: 1),
      body: Center(
          child: FutureBuilder<String>(
        future: getStatus(), // fungsi yang Anda buat untuk mendapatkan status
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String status = snapshot.data ?? '';
              switch (status) {
                case 'belum_bayar':
                  return BelumBayar(context);
                case 'pesanan_selesai':
                  return selesai(context);
                case 'pesanan_ditolak':
                  return ditolak(context);
                case 'pesanaan_diantar':
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      diantar(context),
                      const SizedBox(height: 20),
                      diterima(context),
                    ],
                  );
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
        color: Colors.grey
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
      color: Colors.yellow
    ),
    child: const Text("pesanan sedang di cek"),
  );
}

Widget ditolak(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.red
    ),
    child: const Text("pesanan Ditolak penjual"),
  );
}

Widget diantar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.grey
    ),
    child: const Text("pesanan diantar"),
  );
}

Widget selesai(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.green
    ),
    child: const Text("pesanan sudah di antar"),
  );
}

Widget diterima(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      await setStatusSampai();
      await pembersiahanCart();
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => Monitoringstatus(), // Kirimkan item ke NextPage
        ),
      );
      // Anda bisa menambahkan aksi yang diinginkan saat Container diklik di sini
    },
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.green
      ),
      child: const Text("sudah sampai"),
    ),
  );
}
}
