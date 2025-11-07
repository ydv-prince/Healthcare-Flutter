import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare/intropage.dart';

class Splachscreen extends StatefulWidget {
  const Splachscreen({super.key});

  @override
  State<Splachscreen> createState() => _SplachscreenState();
}

class _SplachscreenState extends State<Splachscreen> {
  @override
  void initState(){
    super.initState();
    // ✅ CRITICAL FIX: Ensure pushReplacement is used after the timer
    Timer(const Duration(seconds:2),(){
      // Navigate to the introduction/pre-login screen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder:(context) => const Intropage()),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB), 
      body: Stack(
        children: [
          // Top Pills (omitted for brevity)
          // Bottom Medical Items (omitted for brevity)
          
          // Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://example.com/your-healthcare-logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_hospital,
                    size: 100,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Healthcare', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 5),
                const Text('Medical app', style: TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}