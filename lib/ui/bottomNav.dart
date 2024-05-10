import 'package:flutter/material.dart';
import 'package:kuis_webapi/ui/home.dart';

class BottomNavigasiBar extends StatefulWidget {
  
  final int inputan;
  const BottomNavigasiBar({super.key, required this.inputan});
  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _BottomNavigasiBarState createState() => _BottomNavigasiBarState();
}

class _BottomNavigasiBarState extends State<BottomNavigasiBar> {
  // ignore: non_constant_identifier_names
  var menu_icon = [
    Icons.home,
    Icons.calendar_month,
    Icons.person,
  ];

  // ignore: non_constant_identifier_names
  var menu_label = ["Beranda", "Riwayat", "Doktor"];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.inputan;
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      currentIndex: selectedIndex,
      onTap: (index) {
      // Lakukan sesuatu untuk semua item di sini

      if (index == 0) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            // ignore: non_constant_identifier_names
            builder: (Context) => Home(),
          ),
          (route) => false);
        // Lakukan sesuatu untuk item pertama di sini
      } else if (index == 1) {
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     // ignore: non_constant_identifier_names
        //     builder: (Context) => const riwayatTransaksi(),
        //   ),
        //   (route) => false);
        // Lakukan sesuatu untuk item kedua di sini
      } else if (index == 2) {
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     // ignore: non_constant_identifier_names
        //     builder: (Context) => const daftar_dokter(),
        //   ),
        //   (route) => false);
        // Lakukan sesuatu untuk item ketiga di sini
      }},
      items: menu_icon
          .asMap()
          .entries
          .map((e) => BottomNavigationBarItem(
                icon: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: selectedIndex == e.key
                        ? const Color.fromARGB(255, 135, 203, 198)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: selectedIndex == e.key
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4.9,
                              offset: const Offset(0, 0),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(e.value,size: 40,),
                      Text(
                        menu_label[e.key],
                        style: TextStyle(
                            color: selectedIndex == e.key
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 8),
                            textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                label: '',
              ))
          .toList(),
    );
  }
}