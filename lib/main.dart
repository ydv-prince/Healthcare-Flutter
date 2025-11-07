import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:healthcare/splash_screen/splachscreen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Widget initialScreen;

  try {
    await Firebase.initializeApp(); 
    
    // If successful, navigate to the splash screen
    initialScreen = const Splachscreen(); 

  } catch (e) {
    // Display a high-visibility error screen if init fails
    print("FATAL FIREBASE INIT ERROR: $e");
    initialScreen = ErrorFallbackScreen(error: e.toString());
  }

  // Passing the resolved Widget to MyApp
  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  // ⚠️ FIX: This field needs to be public for the MaterialApp to access it correctly.
  final Widget initialScreen;
  
  // The constructor is correct
  const MyApp({super.key, required this.initialScreen}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), 
        useMaterial3: true,
      ),
      // ⚠️ FIX: You use the variable name defined above!
      home: initialScreen, 
    );
  }
}

// 🛑 Fallback Screen (for errors)
class ErrorFallbackScreen extends StatelessWidget {
  final String error;
  
  const ErrorFallbackScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 60),
              const SizedBox(height: 20),
              const Text(
                "CRITICAL STARTUP ERROR",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "The app failed to initialize the backend.\nError: $error",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}