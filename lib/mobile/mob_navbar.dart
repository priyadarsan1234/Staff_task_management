import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Dashboard.dart';
import 'package:flutter_application_1/scanner_page.dart';
import 'package:flutter_application_1/mobile/ImageList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  
  int _currentIndex = 1;
  late String pickedImagePath;
  final List<Widget> _pages = [
    QrCodeScanner(),
    Dashboard(),
    ImageList(),
  ];

  String name = '';

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.get(Uri.parse('https://creativecollege.in/Flutter/Profile.php?id=$userID'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData is List && jsonData.isNotEmpty) {
        final firstElement = jsonData[0];
        setState(() {
          name = firstElement['name'];
        });
      } else {
        setState(() {
          name = 'Data not found';
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
    fetchData();
  }

   Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // const _color2 = Color(0xFFF09FDE);
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: _color1,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //       bottomLeft: Radius.circular(100),
      //       bottomRight: Radius.circular(100),
      //     ),
      //   ),
      //   actions: <Widget>[
      //     Container(
      //       margin: EdgeInsets.only(right: 10.0),
      //       child: GestureDetector(
      //         onTap: () {
      //           Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => Profile(),
      //       ),
      //     );
      //         },
      //         child: CircleAvatar(
      //           radius: 20,
      //           backgroundImage: _pickedImage == null
      //               ? AssetImage('assets/images/technocart.png')
      //               : FileImage(File(_pickedImage!.path)) as ImageProvider<Object>?,
      //         ),
      //       ),
      //     ),
      //   ],
      //   title: Text('HI $name'),
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: Color(0xFFC21E56),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
                // if (index ==1) {
                 
                // }
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code),
                label: 'Attendance',
                backgroundColor: Color(0xFFC21E56),
              ),
              
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.contact_phone),
              //   label: 'Student Contact',
              //   backgroundColor: Color(0xFFC21E56),
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.list),
              //   label: 'Task Details',
              //   backgroundColor: Color(0xFFC21E56),
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.task),
              //   label: 'Task Management',
              //   backgroundColor: Color(0xFFC21E56),
              // ),
             
               BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'DashBoard',
                backgroundColor: Color(0xFFC21E56),
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.note_sharp),
                label: 'Notice',
                backgroundColor: Color(0xFFC21E56),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
