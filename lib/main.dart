import 'package:flutter/material.dart';
import './hindi_trans.dart';
import "./home/home.dart";
import 'package:dio/dio.dart';
/*
/// Flutter code sample for [BottomNavigationBar].

void main() => runApp(const BottomNavigationBarExampleApp());

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}*/

import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _Login(title: 'Flutter Demo Home Page'),
    );
  }
}

class _Login extends StatefulWidget {
  final String title;
  const _Login({super.key, required this.title});

  @override
  State<_Login> createState() => __LoginState();
}

class __LoginState extends State<_Login> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  bool _isError = false; // Track whether there is an error
      String selectedLanguage = 'English'; // Default language
 Translator translator = Translator();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 19, 22),
      appBar: AppBar(
        title: const Text(
          'ZORA',
          
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children:<Widget> [
               Text(
                translator.translate(selectedLanguage, "server_ip"),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 214, 112, 29),
                ),
              ),
              Textbox(
                hintText: "Enter Server IP",
                controller: _controller1,
                isError: _isError,
                 // Pass error state to Textbox
              ),
                  Text(
                translator.translate(selectedLanguage, "select-language"),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 214, 112, 29),
                ),
              ),
                DropdownButton<String>(
              value: selectedLanguage,
              items: <String>['English', 'Hindi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,style: TextStyle(color:Colors.black),),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
            ),
             
              Container(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [button("Continue")],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container button(String a) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          String ip = _controller1.text;
          
          if (ip.isNotEmpty) {
            bool isValid = await getinfo(ip);
            if (isValid) {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AudioPage (ip:ip,lang:selectedLanguage)),
              );
              
              print(_controller1.text);
            } else {
              setState(() {

                _isError = true; // Set error state if the IP is invalid
              });
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        child: Text(a),
      ),
    );
  }

  Future<bool> getinfo(String ip) async {
          BaseOptions options = new BaseOptions(
          baseUrl: "http://$ip:5000",
          connectTimeout: Duration(milliseconds: 5000),
          receiveTimeout: Duration(milliseconds: 5000),
            );

        try {
        final response = await Dio(options).get(
          "http://$ip:5000/check_endpoint",);
          print('response received');
        return true;
           } 
      on DioException catch (e) {
          if (e.type == DioExceptionType.receiveTimeout) {
            print('Receive timeout!');
            return false;
          } else if (e.type == DioExceptionType.sendTimeout) {
            print('Send timeout!');
            return false;
          } else {
            print('Request failed: $e');
            return false;
          }
        }
  }

}

class Textbox extends StatelessWidget {
  const Textbox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.isError,
  });

  final String hintText;
  final TextEditingController controller;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black),
          prefixIcon: const Icon(Icons.public),
          prefixIconColor: const Color.fromARGB(255, 17, 13, 1),
          filled: true,
          fillColor: isError ? Colors.red : Colors.white,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
      ),
    );
  }
}
