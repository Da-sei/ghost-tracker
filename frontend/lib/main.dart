import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '法人図鑑 @鳥取県',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MyHomePage(title: '法人図鑑 @鳥取県'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<ApiResults>> futureApiResults;
  @override
  void initState() {
    super.initState();
    futureApiResults = fetchApiResults();
  }

  late String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Text(widget.title, style: GoogleFonts.zenMaruGothic()),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '法人名/法人番号を入力してください'
                ),
                onChanged: (text) {
                  setState(() {
                    name = text;
                    futureApiResults = fetchApiRequest(name);
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<ApiResults>>(
                future: futureApiResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('データがありません'));
                  }

                  final results = snapshot.data!;
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final company = results[index];
                      return Container(
                        height: 100,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(1, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(10)
                        ),                                
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(company.name, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(company.address),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiResults {
  final String corporate_number;
  final String name;
  final String name_kana;
  final String address;
  final String category;

  ApiResults({
    required this.corporate_number,
    required this.name,
    required this.name_kana,
    required this.address,
    required this.category,
  });

  factory ApiResults.fromJson(Map<String, dynamic> json) {
    return ApiResults(
      corporate_number: json['corporate_number'],
      name: json['name'],
      name_kana: json['name_kana'],
      address: json['address'],
      category: json['category']
    );
  }
}

Future<List<ApiResults>> fetchApiResults() async {
  final response = await http.get(Uri.parse('http://localhost:3000/companies'));
  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    return body.map((item) => ApiResults.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load API params');
  }
}

Future<List<ApiResults>> fetchApiRequest(String name) async {
  final uri = Uri.http('localhost:3000', '/companies', {'name': name});
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> body = json.decode(response.body);
    return body.map((item) => ApiResults.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load API params');
  }
}