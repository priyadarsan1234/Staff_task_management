import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RedFlagPage extends StatefulWidget {
  @override
  _RedFlagPageState createState() => _RedFlagPageState();
}

class _RedFlagPageState extends State<RedFlagPage> {
  List<dynamic> _data = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    const url = 'https://creativecollege.in/Flutter/Work/showredflag.php'; // Replace with your PHP script URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        
        // Convert COUNT to int and sort based on it in descending order
        fetchedData.sort((a, b) {
          final countA = int.tryParse(a['COUNT']) ?? 0;
          final countB = int.tryParse(b['COUNT']) ?? 0;
          return countB.compareTo(countA);
        });

        setState(() {
          _data = fetchedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _clearFlag(String id) async {
    final url = 'https://creativecollege.in/Flutter/Work/clear_red_flag.php'; // Replace with your PHP script URL for clearing flags

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'id': id}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Flag cleared successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchData(); // Refresh the data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear flag: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Color.fromARGB(255, 194, 30, 86);
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: _color1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          'Red Flag Faculty',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Times New Roman',
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('NO DATA FOUNT!!!', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)))
              : ListView.separated(
                  padding: EdgeInsets.all(8.0),
                  itemCount: _data.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                  ),
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    return Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(Icons.flag, color: Colors.white, size: 36),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['ID']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${item['LAST_FLAG_DATE'] ?? 'No data'}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14,fontFamily: 'Times New Roman',),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Text(
                            '${item['COUNT']}',
                            style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Times New Roman',),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_outlined, color: Colors.red, size: 24,),
                            onPressed: () => _clearFlag(item['ID']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
