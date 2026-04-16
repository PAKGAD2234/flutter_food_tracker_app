import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/service/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_food_tracker_app/models/food.dart';

class UpdateDeleteFoodTrackerUi extends StatefulWidget {
  final Food food;

  const UpdateDeleteFoodTrackerUi({super.key, required this.food});

  @override
  State<UpdateDeleteFoodTrackerUi> createState() => _UpdateDeleteFoodTrackerUiState();
}

class _UpdateDeleteFoodTrackerUiState extends State<UpdateDeleteFoodTrackerUi> {
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

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลเดิม
    foodNameCtrl.text = widget.food.foodName ?? '';
    selectedMeal = widget.food.foodMeal ?? '';
    foodMealCtrl.text = selectedMeal;
    foodPersonCtrl.text = widget.food.foodPerson?.toString() ?? '';
    foodPriceCtrl.text = widget.food.foodPrice?.toString() ?? '';
    if (widget.food.foodDate != null) {
      foodDateCtrl.text = DateFormat('yyyy-MM-dd').format(widget.food.foodDate!);
    }
    foodImageUrl = widget.food.foodImageUrl;
  }

  // -------- Pick Image --------
  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        file = picked;
        fileBytes = bytes;
        foodImageUrl = null; // รีเซ็ต URL เดิมถ้าเลือกรูปใหม่
      });
    }
  }

  // -------- Pick Date --------
  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.food.foodDate ?? DateTime.now(),
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

  // -------- Update --------
  Future<void> update() async {
    // 🔥 เช็คมื้ออาหาร
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

      // 🔥 upload รูปใหม่ถ้ามี
      String? finalImageUrl = foodImageUrl;
      if (file != null) {
        finalImageUrl = await service.uploadFile(file!);
      }

      // 🔥 สร้าง Food object สำหรับ update
      final updatedFood = Food(
        foodName: foodNameCtrl.text,
        foodMeal: selectedMeal,
        foodPerson: int.tryParse(foodPersonCtrl.text) ?? 0,
        foodPrice: double.tryParse(foodPriceCtrl.text) ?? 0,
        foodDate: DateTime.parse(foodDateCtrl.text),
        foodImageUrl: finalImageUrl,
        createdAt: widget.food.createdAt, // ใช้ createdAt เดิม
      );

      await service.updateFood(widget.food.id!, updatedFood);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อัพเดทสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // ส่ง true เพื่อบอกว่าอัพเดทแล้ว
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('อัพเดทไม่สำเร็จ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // -------- Delete --------
  Future<void> delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบข้อมูลนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final service = SupabaseService();

      // ลบรูปภาพถ้ามี
      if (widget.food.foodImageUrl != null && widget.food.foodImageUrl!.isNotEmpty) {
        await service.deleteFile(widget.food.foodImageUrl!);
      }

      // ลบข้อมูล
      await service.deleteFood(widget.food.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // ส่ง true เพื่อบอกว่าลบแล้ว
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบไม่สำเร็จ: $e'),
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
          'Food Tracker (แก้ไข)',
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
              fileBytes != null
                  ? InkWell(
                      onTap: pickImage,
                      child: Image.memory(
                        fileBytes!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : foodImageUrl != null && foodImageUrl!.isNotEmpty
                      ? InkWell(
                          onTap: pickImage,
                          child: Image.network(
                            foodImageUrl!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return InkWell(
                                onTap: pickImage,
                                child: Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 150,
                                  color: Colors.grey[300],
                                ),
                              );
                            },
                          ),
                        )
                      : InkWell(
                          onTap: pickImage,
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 150,
                            color: Colors.grey[300],
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

              // -------- Update --------
              ElevatedButton(
                onPressed: update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width,
                    50,
                  ),
                ),
                child: const Text('อัพเดท',
                    style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 10),

              // -------- Delete --------
              ElevatedButton(
                onPressed: delete,
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