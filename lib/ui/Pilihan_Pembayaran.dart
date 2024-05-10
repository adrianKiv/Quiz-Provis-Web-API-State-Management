import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_webapi/ui/monitoringstatus.dart';


// ignore: camel_case_types
class Pilihan_Pembayaran extends StatefulWidget {
  const Pilihan_Pembayaran({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Pilihan_PembayaranState createState() => _Pilihan_PembayaranState();
}

Future<void> setStatusBayar() async {
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
    print('Berhasil mengatur status menjadi bayar');
  } else {
    print('Gagal mengatur status');
    throw Exception('Failed to set status');
  }
}

// ignore: camel_case_types
class _Pilihan_PembayaranState extends State<Pilihan_Pembayaran> {
  int pilihOpsi = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 10,
        shadowColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
        child: Column(
          children: [
            Text("Silahkan pilih metode pembayaran yang akan anda gunakan"),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(242, 244, 247, 100),
                borderRadius: BorderRadius.circular(15)
              ),
              child: ListTile(
                leading: Image.asset('assets/images/bca_logo.png'),
                title: Text("BCA Virtual Account", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),),
                trailing: Radio<int>(
                  activeColor: Color.fromRGBO(128, 211, 211, 100),
                  hoverColor: Color.fromRGBO(128, 211, 211, 100),
                  value: 1,
                  groupValue: pilihOpsi,
                  onChanged: (value) {
                    setState(() {
                      pilihOpsi = value!;
                      print("Button value: $value");
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(242, 244, 247, 100),
                borderRadius: BorderRadius.circular(15)
              ),
              child: ListTile(
                leading: Image.asset('assets/images/bni_logo.png'),
                title: Text("BNI Virtual Account",style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),),
                trailing: Radio<int>(
                  activeColor: Color.fromRGBO(128, 211, 211, 100),
                  hoverColor: Color.fromRGBO(128, 211, 211, 100),
                  value: 2,
                  groupValue: pilihOpsi,
                  onChanged: (value) {
                    setState(() {
                      pilihOpsi = value!;
                      print("Button value: $value");
                    });
                  },
                ),
              ),
            ),
            
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavigasiBar(context),
    );
  }

  BottomAppBar _BottomNavigasiBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: GestureDetector(
        onTap: () async {
          await setStatusBayar();
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Monitoringstatus()),
      );
        },
        child: Container(
          width: 350,
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 135, 203, 198),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4.9,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: const Text(
            'Bayar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}