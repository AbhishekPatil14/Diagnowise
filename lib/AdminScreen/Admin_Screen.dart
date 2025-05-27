import 'package:flutter/material.dart';

import 'AddDoctor/Add_Doctor_Screen.dart';
import 'AddMedicine/Add_Medicine_Screen.dart';
import 'RemoveDoctor/Remove_Doctor_Screen.dart';
import 'UpdateDoctor/Update_Doctor_Screen.dart';
import 'ViewDoctor/View_Doctor_Screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AddDoctorWidget(),
    UpdateDoctorWidget(),
    RemoveDoctorWidget(),
    ViewDoctorWidget(),
    AddMedicineWidget(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.person_add),
      label: 'Add',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.edit),
      label: 'Update',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.delete),
      label: 'Remove',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.visibility),
      label: 'Doctors',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.medical_services),
      label: 'Medicine',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.teal;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: pages[selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          selectedItemColor: themeColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: navBarItems,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
