import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Workdelay extends StatefulWidget {
  @override
  _WorkdelayState createState() => _WorkdelayState();
}

class _WorkdelayState extends State<Workdelay> {
  late Future<Map<String, Map<String, dynamic>>> _data;

  final String baseUrl =
      'https://creativecollege.in/Flutter/Work/workdelay.php';

  Future<Map<String, Map<String, dynamic>>> fetchData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      // Parse the JSON data
      List<dynamic> data = json.decode(response.body);

      // Group the data by 'ID'
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
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _data = fetchData(); // Fetch data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data from API'),
        backgroundColor: Colors.blueAccent,
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
            // Sort the keys (IDs) alphabetically
            final sortedKeys = data.keys.toList()..sort();

            return ListView(
              children: sortedKeys.map((key) {
                final group = data[key]!;
                final workItems = group['items'] as List<dynamic>;
                final count = group['count'] as int;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '$key ($count)',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    ...workItems.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.only(
                            left: 16, right: 16, bottom: 0, top: 0),
                        leading: IconButton(
                          icon: Icon(Icons.flag, size: 23.0, color: Colors.red),
                          onPressed: () {
                            // Define what happens when the button is pressed
                            print('IconButton pressed');
                          },
                        ),
                        title: Text(
                          item['TITLE'] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                        subtitle: Text(
                          item['ID'] ?? 'No ID',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(item['ADDDATE'] ?? 'No Date'),
                            Text(item['STATUS'] ?? 'No Status'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            );
          } else {
            return Center(child: Text('No Data Found'));
          }
        },
      ),
    );
  }
}
