import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/view/splash_screen_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// --------------------------------
void main() async {
  // ----ตั้งค่าการใช้งาน supabase ที่จะทำงาน----
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dmrmyvgqrjbzhdyqacqv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtcm15dmdxcmpiemhkeXFhY3F2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTc4NzEsImV4cCI6MjA5MTY3Mzg3MX0.AtzpUFlLf22lBaEEQSoYK7su1GxpehK135a8C2eklsI',
  );

  runApp(
    FlutterfoodtrackerApp(),
  );
}

class FlutterfoodtrackerApp extends StatefulWidget {
  const FlutterfoodtrackerApp({super.key});

  @override
  State<FlutterfoodtrackerApp> createState() => _FlutterfoodtrackerAppState();
}

class _FlutterfoodtrackerAppState extends State<FlutterfoodtrackerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenUi(),
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme
        ),
      ),
    );
  }
}