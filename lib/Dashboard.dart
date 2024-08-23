import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Report_upload.dart';
import 'package:flutter_application_1/attendance/attendance.dart';
import 'package:flutter_application_1/mobile/Staff_Attendance.dart';
import 'package:flutter_application_1/mobile/detailsMobile.dart';
import 'package:flutter_application_1/mobile/mob_add_task.dart';
import 'package:flutter_application_1/mobile/mob_contact_prev.dart';
import 'package:flutter_application_1/mobile/mob_task_mgmt.dart';
import 'package:flutter_application_1/staff_leave.dart';
import 'package:flutter_application_1/student_attendance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile/mob_Profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _color1 = const Color(0xFFC21E56);
  XFile? _pickedImage;
  late String pickedImagePath;
  Map<String, dynamic>? data;
  bool isLoading = true;
  String error = '';

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
      }
    });
  }

  Future<void> fetchData(String id) async {
    final url =
        'https://creativecollege.in/Flutter/Work/singledata_redflag.php?id=$id';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the JSON
        setState(() {
          data = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception
        setState(() {
          error = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors that occur
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
    fetchData("Bhabani@CTC");
  }

  Widget _buildCard(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _color1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: <Widget>[
                Row(
                  children: [
                    Card(
                      color: Colors.white, // Background color of the card
                      elevation: 4.0, // Shadow intensity
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(25.0), // Rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Padding inside the card
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Size the row to fit its content
                          children: [
                            Text(
                              '${data != null && data!.containsKey('COUNT') ? data!['COUNT'] : '0'}',
                              style: const TextStyle(
                                color: Colors
                                    .black, // Changed to black for better visibility on white background
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.flag,
                              color: Colors.red,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profile(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: _pickedImage == null
                        ? const AssetImage('assets/images/technocart.png')
                        : FileImage(File(_pickedImage!.path))
                            as ImageProvider<Object>?,
                  ),
                ),
              ],
            ),
          ),
        ],
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildSmallScreenView();
          } else {
            return _buildLargeScreenView();
          }
        },
      ),
    );
  }

  Widget _buildSmallScreenView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildCard(Icons.phone, 'Student Contact Record', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactPrev(),
              ),
            );
          }),
          _buildCard(Icons.work, 'Work Details', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsMobile(),
              ),
            );
          }),
          _buildCard(Icons.task, 'Task Management', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Task_mgmt(),
              ),
            );
          }),
          _buildCard(Icons.present_to_all, 'Self Attendance', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Staff_Attendanance(),
              ),
            );
          }),
          _buildCard(Icons.report, 'Report', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Report_upload(),
              ),
            );
          }),
          _buildCard(Icons.add_task, 'Add Task', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Mob_Add_Task(),
              ),
            );
          }),
          _buildCard(Icons.leave_bags_at_home, 'Apply Leave', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Leave_Page(),
              ),
            );
          }),
          _buildCard(Icons.present_to_all_rounded, 'Student Attendance', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Attendance(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLargeScreenView() {
    return Center(
      child: SizedBox(
        width: 800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildCard(Icons.phone, 'Student Contact Record', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPrev(),
                  ),
                );
              }),
              _buildCard(Icons.work, 'Work Details', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsMobile(),
                  ),
                );
              }),
              _buildCard(Icons.task, 'Task Management', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Task_mgmt(),
                  ),
                );
              }),
              _buildCard(Icons.present_to_all, 'Self Attendance', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Staff_Attendanance(),
                  ),
                );
              }),
              _buildCard(Icons.report, 'Report', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Report_upload(),
                  ),
                );
              }),
              _buildCard(Icons.add_task, 'Add Task', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Mob_Add_Task(),
                  ),
                );
              }),
              _buildCard(Icons.leave_bags_at_home, 'Apply Leave', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Leave_Page(),
                  ),
                );
              }),
              _buildCard(Icons.present_to_all_rounded, 'Student Attendance',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentAttendance(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
