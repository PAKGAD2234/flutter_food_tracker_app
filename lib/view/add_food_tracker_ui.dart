import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/service/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_food_tracker_app/models/food.dart';

class AddFoodTrackerUi extends StatefulWidget {
  const AddFoodTrackerUi({super.key});

  @override
  State<AddFoodTrackerUi> createState() => _AddFoodTrackerUiState();
}

class _AddFoodTrackerUiState extends State<AddFoodTrackerUi> {
  // -------- Controllers --------
  TextEditingController foodNameCtrl = TextEditingController();
  TextEditingController foodMealCtrl = TextEditingController();
  TextEditingController foodPersonCtrl = TextEditingController();
  TextEditingController foodPriceCtrl = TextEditingController();
  TextEditingController foodDateCtrl = TextEditingController();

  String? foodImageUrl;
  XFile? file;
  Uint8List? fileBytes;

  // -------- Meal Selected --------
  String selectedMeal = '';

  // -------- Pick Image --------
  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        file = picked;
        fileBytes = bytes;
      });
    }
  }

  // -------- Pick Date --------
  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        foodDateCtrl.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // -------- Save --------
  Future<void> save() async {
    // 🔥 เช็คมื้ออาหาร (ตัวนี้เธอลืมกันพลาด)
    if (selectedMeal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกมื้ออาหาร')),
      );
      return;
    }

    if (foodNameCtrl.text.isEmpty ||
        foodPersonCtrl.text.isEmpty ||
        foodPriceCtrl.text.isEmpty ||
        foodDateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาป้อนข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final service = SupabaseService();

      // 🔥 upload รูป
      if (file != null) {
        foodImageUrl = await service.uploadFile(file!);
      }

      // 🔥 กัน parse พัง
      final food = Food(
        foodName: foodNameCtrl.text,
        foodMeal: selectedMeal, // 🔥 ใช้ selectedMeal แทน
        foodPerson: int.tryParse(foodPersonCtrl.text) ?? 0,
        foodPrice: double.tryParse(foodPriceCtrl.text) ?? 0,
        foodDate: DateTime.parse(foodDateCtrl.text),
        foodImageUrl: foodImageUrl,
        createdAt: DateTime.now(), // 🔥 เพิ่ม created_at
      );

      await service.insertFood(food);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกไม่สำเร็จ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // -------- Meal Button --------
  Widget mealButton(String meal) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedMeal = meal;
              foodMealCtrl.text = meal;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedMeal == meal ? Colors.green : Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            meal,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 232, 43, 18),
        title: const Text(
          'Food Tracker (เพิ่ม)',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(45, 30, 45, 50),
          child: Column(
            children: [
              // -------- Image --------
              fileBytes == null
                  ? InkWell(
                      onTap: pickImage,
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: 150,
                        color: Colors.grey[300],
                      ),
                    )
                  : InkWell(
                      onTap: pickImage,
                      child: Image.memory(
                        fileBytes!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

              const SizedBox(height: 20),

              // -------- Food Name --------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('กินอะไร'),
              ),
              TextField(controller: foodNameCtrl),

              const SizedBox(height: 20),

              // -------- Meal --------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('กินมื้อไหน'),
              ),
              Row(
                children: [
                  mealButton('เช้า'),
                  mealButton('กลางวัน'),
                  mealButton('เย็น'),
                  mealButton('ว่าง'),
                ],
              ),

              const SizedBox(height: 20),

              // -------- Price --------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('กินไปเท่าไหร่'),
              ),
              TextField(
                controller: foodPriceCtrl,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // -------- Person --------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('กินกันกี่คน'),
              ),
              TextField(
                controller: foodPersonCtrl,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // -------- Date --------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('กินวันไหน'),
              ),
              TextField(
                controller: foodDateCtrl,
                readOnly: true,
                onTap: pickDate,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 30),

              // -------- Save --------
              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width,
                    50,
                  ),
                ),
                child: const Text('บันทึก', 
                style: TextStyle(color: Colors.white)
                
                
                ),
                
              ),

              const SizedBox(height: 10),

              // -------- Cancel --------
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    foodNameCtrl.clear();
                    foodMealCtrl.clear();
                    foodPersonCtrl.clear();
                    foodPriceCtrl.clear();
                    foodDateCtrl.clear();
                    file = null;
                    selectedMeal = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width,
                    50,
                  ),
                ),
                child: const Text('ลบข้อมูล',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}