import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('minimal save')),
      body: Center(
          child: Text("Selected Page: ${_navBarItems[_selectedIndex].label}")),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _navBarItems,
      ),
    );
  }
}

const _navBarItems = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.notifications_active_outlined),
    selectedIcon: Icon(Icons.notifications_active),
    label: 'monitoring status',
  ),
  NavigationDestination(
    icon: Icon(Icons.shopping_bag_outlined),
    selectedIcon: Icon(Icons.shopping_bag),
    label: 'keranjang',
  ),
];
