import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Workdelay extends StatefulWidget {
  @override
  _WorkdelayState createState() => _WorkdelayState();
}

class _WorkdelayState extends State<Workdelay> {
  late Future<Map<String, Map<String, dynamic>>> _data;
  late Future<Map<String, DateTime?>> _redFlagDates;

  final String baseUrl =
      'https://creativecollege.in/Flutter/Work/workdelay.php';
  final String redFlagUrl =
      'https://creativecollege.in/Flutter/Work/showredflag.php';

  Future<Map<String, Map<String, dynamic>>> fetchData() async {
    final response = await http.get(Uri.parse(baseUrl));

    print('Response body from fetchData: ${response.body}');

    try {
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          List<dynamic> data = jsonResponse;

          Map<String, Map<String, dynamic>> groupedData = {};
          for (var item in data) {
            String id = item['ID'] ?? 'Unknown';
            if (!groupedData.containsKey(id)) {
              groupedData[id] = {
                'count': 0,
                'items': [],
              };
            }
            groupedData[id]!['count'] = groupedData[id]!['count'] + 1;
            groupedData[id]!['items'].add(item);
          }

          return groupedData;
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error parsing JSON in fetchData: $e');
      throw Exception('Error parsing JSON');
    }
  }

  Future<Map<String, DateTime?>> fetchRedFlagDates() async {
    final response = await http.get(Uri.parse(redFlagUrl));

    print('Response body from fetchRedFlagDates: ${response.body}');

    try {
      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty ||
            response.body.trim() == 'No Data Found') {
          return {}; // Return an empty map if no data found
        }

        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          List<dynamic> data = jsonResponse;

          Map<String, DateTime?> redFlags = {};
          for (var item in data) {
            String id = item['ID'];
            String lastFlagDateStr = item['LAST_FLAG_DATE'] ?? '';
            DateTime? lastFlagDate;
            if (lastFlagDateStr.isNotEmpty) {
              lastFlagDate = DateTime.tryParse(lastFlagDateStr);
            }
            redFlags[id] = lastFlagDate;
          }

          return redFlags;
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception('Failed to load red flag data');
      }
    } catch (e) {
      print('Error parsing JSON in fetchRedFlagDates: $e');
      return {}; // Return an empty map in case of error
    }
  }

  Future<void> redflag(String id) async {
    final String updateUrl =
        'https://creativecollege.in/Flutter/Work/redflag.php';
    try {
      final response = await http.post(
        Uri.parse(updateUrl),
        body: {'ID': id},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${responseData['message']}'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _data = fetchData(); // Refresh data to reflect changes
            _redFlagDates = fetchRedFlagDates(); // Refresh red flag dates
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HTTP Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _data = fetchData();
    _redFlagDates = fetchRedFlagDates();
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Color.fromARGB(255, 194, 30, 86);
    const _color2 = Color.fromARGB(255, 242, 242, 242);

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
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return FutureBuilder<Map<String, DateTime?>>(
              future: _redFlagDates,
              builder: (context, redFlagSnapshot) {
                if (redFlagSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (redFlagSnapshot.hasError) {
                  return Center(child: Text('Error: ${redFlagSnapshot.error}'));
                } else if (redFlagSnapshot.hasData) {
                  final redFlagDates = redFlagSnapshot.data!;
                  final now = DateTime.now();
                  final sortedKeys = data.keys.toList()..sort();

                  return ListView(
                    padding: const EdgeInsets.all(10.0),
                    children: sortedKeys.map((key) {
                      final group = data[key]!;
                      final workItems = group['items'] as List<dynamic>;
                      final count = group['count'] as int;
                      final lastFlagDate = redFlagDates[key];

                      final isRecentlyFlagged = lastFlagDate != null &&
                          now.difference(lastFlagDate).inDays < 7;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[100]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Icon(Icons.group, color: _color1),
                                SizedBox(width: 8.0),
                                Text(
                                  '$key ($count)',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: _color1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            ...workItems.map((item) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: IconButton(
                                    icon: Icon(
                                      isRecentlyFlagged
                                          ? Icons.flag
                                          : Icons.outlined_flag,
                                      size: 24.0,
                                      color: isRecentlyFlagged
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      final id = item['ID'];
                                      redflag(id);
                                    },
                                  ),
                                  title: Text(
                                    item['TITLE'] ?? 'No Title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                      fontFamily: 'Times New Roman',
                                    ),
                                  ),
                                  subtitle: Text(
                                    item['ID'] ?? 'No ID',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.grey[600],
                                      fontFamily: 'Times New Roman',
                                    ),
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        item['ADDDATE'] ?? 'No Date',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                          color: Colors.grey[700],
                                          fontFamily: 'Times New Roman',
                                        ),
                                      ),
                                      Text(
                                        item['STATUS'] ?? 'No Status',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                          color: Colors.grey[700],
                                          fontFamily: 'Times New Roman',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Center(child: Text('No Data Found'));
                }
              },
            );
          } else {
            return Center(child: Text('No Data Found'));
          }
        },
      ),
    );
  }
}
