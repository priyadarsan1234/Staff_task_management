import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class Attendance extends StatefulWidget {
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  String selectedCourse = 'BBA';
  String selectedSemesterGroup = '1st';
  Map<String, dynamic>? allData;
  Map<String, dynamic>? filteredData;
  DateTime currentDate = DateTime.now();
  Map<String, Map<String, dynamic>> attendanceStatus =
      {}; // To track attendance status

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        allData = data;
        filteredData = _filterData(data, selectedCourse, selectedSemesterGroup);
        _initializeAttendanceStatus(filteredData);
      });
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/New_attendance/Fetch_student_data.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched Data: $data'); // Debugging line
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Map<String, dynamic> _filterData(
      Map<String, dynamic> data, String course, String semesterGroup) {
    final filtered = <String, dynamic>{};
    data.forEach((key, records) {
      filtered[key] = (records as List<dynamic>).where((record) {
        final semester = record['SEMESTER'];
        if (semesterGroup == '1st') {
          return ['1st', '2nd'].contains(semester) &&
              record['COURSE'] == course;
        } else if (semesterGroup == '2nd') {
          return ['3rd', '4th'].contains(semester) &&
              record['COURSE'] == course;
        } else if (semesterGroup == '3rd') {
          return ['5th', '6th'].contains(semester) &&
              record['COURSE'] == course;
        }
        return false;
      }).toList();
    });
    return filtered;
  }

  void _initializeAttendanceStatus(Map<String, dynamic>? data) {
    final status = <String, Map<String, dynamic>>{};
    if (data != null) {
      data.values.expand((records) => records).forEach((record) {
        status[record['ID']] = {
          'name': record['NAME'],
          'id': record['ID'],
          'present': false,
        };
      });
    }
    setState(() {
      attendanceStatus = status;
    });
  }

  void _toggleAttendance(String id) {
    setState(() {
      final student = attendanceStatus[id];
      if (student != null) {
        student['present'] = !student['present'];
      }
    });
  }

Future<void> _submitAttendance() async {
  if (attendanceStatus.isEmpty) return;

  final url = Uri.parse(
    'https://creativecollege.in/Flutter/New_attendance/attendance.php',
  );

  final List<Map<String, dynamic>> attendanceList = attendanceStatus.values.map((student) {
    return {
      'id': student['id'],
      'present': student['present'] ? 1 : 0,
      'date': DateFormat('yyyy-MM-dd').format(currentDate),
      'semester_group': selectedSemesterGroup,
    };
  }).toList();

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(attendanceList),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseBody['status'] == 'success') {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['message'] ?? 'Attendance submitted successfully'),
        ));
      } else if (responseBody['status'] == 'error') {
        // Handle specific error messages
        final errorMessage = responseBody['message'];
        if (errorMessage is List) {
          // Join all error messages if they are in a list
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage.join('\n')),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage ?? 'Failed to submit attendance'),
          ));
        }
      }
    } else {
      // Handle HTTP error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit attendance: HTTP ${response.statusCode}'),
      ));
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error submitting attendance'),
    ));
  }
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
          // Filter buttons for course
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'BBA';
                    filteredData = _filterData(
                        allData ?? {}, selectedCourse, selectedSemesterGroup);
                    _initializeAttendanceStatus(filteredData);
                  });
                },
                child: Text('BBA'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'BSC-C';
                    filteredData = _filterData(
                        allData ?? {}, selectedCourse, selectedSemesterGroup);
                    _initializeAttendanceStatus(filteredData);
                  });
                },
                child: Text('BSC-CS(H)'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCourse = 'BCA';
                    filteredData = _filterData(
                        allData ?? {}, selectedCourse, selectedSemesterGroup);
                    _initializeAttendanceStatus(filteredData);
                  });
                },
                child: Text('BCA'),
              ),
            ],
          ),
          // Filter buttons for semester group
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSemesterGroup = '1st';
                    filteredData = _filterData(
                        allData ?? {}, selectedCourse, selectedSemesterGroup);
                    _initializeAttendanceStatus(filteredData);
                  });
                },
                child: Text('1st & 2nd'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSemesterGroup = '2nd';
                    filteredData = _filterData(
                        allData ?? {}, selectedCourse, selectedSemesterGroup);
                    _initializeAttendanceStatus(filteredData);
                  });
                },
                child: Text('3rd & 4th'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSemesterGroup = '3rd';
                    filteredData = _filterData(
                        allData ?? {}, selectedCourse, selectedSemesterGroup);
                    _initializeAttendanceStatus(filteredData);
                  });
                },
                child: Text('5th & 6th'),
              ),
            ],
          ),
          // Display filtered data
          Expanded(
            child: filteredData == null
                ? Center(child: CircularProgressIndicator())
                : filteredData!.isEmpty
                    ? Center(child: Text('No data available'))
                    : ListView(
                        children: filteredData!.values
                            .expand((records) => records)
                            .map<Widget>((record) {
                          final id = record['ID'];
                          final name = record['NAME'];
                          final isPresent =
                              attendanceStatus[id]?['present'] ?? false;

                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    '$name',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'ID: $id',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  trailing: Checkbox(
                                    value: isPresent,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        _toggleAttendance(id);
                                      }
                                    },
                                  ),
                                ),
                                Divider(thickness: 1), // Underline effect
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ),
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submitAttendance,
              child: Text('Submit Attendance'),
            ),
          ),
        ],
      ),
    );
  }
}
