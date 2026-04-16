import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/view/show_all_food_tracker.ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
   void initState() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ShowAllFoodTrackerUi(),
        ),
      );
    });
    super.initState();
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 43, 18),
      body: Stack(
        children: [
          //ชั้นที่หนึ่ง
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/hot-pot.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'Food Tracker',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 251, 233, 31),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '🍔🍟🌭🍕🥓🍿',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 251, 233, 31),
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 30),
                CircularProgressIndicator(
                  color: const Color.fromARGB(255, 251, 233, 31),
                ),
              ],
            ),
          ),
          // ชั้นที่ 2
         
        ],
      ),
    );
  }
}