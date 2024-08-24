import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/web/admin_details.dart';
import 'package:flutter_application_1/mobile/Report_retrive.dart';
import 'package:animate_do/animate_do.dart';

class StaffList extends StatefulWidget {
  const StaffList({Key? key}) : super(key: key);

  @override
  State<StaffList> createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  List<dynamic> items = [];

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/staff_list.php');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
        items.sort((a, b) => a['name'].compareTo(b['name']));
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Color.fromARGB(255, 194, 30, 86);
    return Scaffold(
      
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return FadeInDown(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: 100 * index),
            child: StaffCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final Map<String, dynamic> item;

  StaffCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            item['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 194, 30, 86),
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      '${item['name']}\nWork Status & Monthly Report',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Select an option to view details or report.'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details_admin_web(
                                name: item['name'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 194, 30, 86), // Updated parameter
                        ),
                        child: const Text('Status'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Report_Retrive(
                                id: item['user_name'],
                                name: item['name'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 194, 30, 86), // Updated parameter
                        ),
                        child: const Text('Report'),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 194, 30, 86), // Updated parameter
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Show Status',style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
    );
  }
}
