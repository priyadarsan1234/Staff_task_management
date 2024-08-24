import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Feedbackpage extends StatefulWidget {
  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedbackpage> {
  late Future<Map<String, List<Map<String, dynamic>>>> futureData;
  String selectedCourse = 'All'; // State for selected course

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchData() async {
    final response = await http.get(Uri.parse('https://creativecollege.in/Flutter/Feedback/fetbackfetch.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      Map<String, List<Map<String, dynamic>>> groupedData = {};

      for (var item in data) {
        String week = item['weak'];
        if (!groupedData.containsKey(week)) {
          groupedData[week] = [];
        }
        groupedData[week]!.add(item as Map<String, dynamic>);
      }

      return groupedData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Map<String, List<Map<String, dynamic>>> filterData(
      Map<String, List<Map<String, dynamic>>> data, String course) {
    if (course == 'All') {
      return data;
    }

    final filteredData = <String, List<Map<String, dynamic>>>{};
    data.forEach((week, items) {
      final filteredItems = items.where((item) => item['cource'] == course).toList();
      if (filteredItems.isNotEmpty) {
        filteredData[week] = filteredItems;
      }
    });
    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Color.fromARGB(255, 194, 30, 86);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _color1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Times New Roman',
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'All';
                  });
                },
                child: Text('All', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'BBA';
                  });
                },
                child: Text('BBA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'BCA';
                  });
                },
                child: Text('BCA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'BSC';
                  });
                },
                child: Text('BSC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo[900],
                      strokeWidth: 4,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No feedback available at this time', style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                final groupedData = filterData(snapshot.data!, selectedCourse);

                if (groupedData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No data available for the selected course', style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.all(12.0),
                  children: groupedData.keys.map((week) {
                    final items = groupedData[week]!;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        title: Text('Week $week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[800], fontFamily: 'Times New Roman')),
                        tilePadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8.0),
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo[100],
                                child: Icon(Icons.person, color: Colors.indigo[900]),
                              ),
                              title: Text(item['teacher_name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Times New Roman')),
                              subtitle: Text(
                                'Subject: ${item['subject']}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Feedback: ${item['average_score']}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.indigo[800], fontFamily: 'Times New Roman'),
                                  ),
                                  Text(
                                    '${item['cource']}',
                                    style: TextStyle(fontSize: 10, color: Colors.indigo[800], fontFamily: 'Times New Roman'),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
