import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/service/supabase_service.dart';
import 'package:flutter_food_tracker_app/view/add_food_tracker_ui.dart';
import 'package:flutter_food_tracker_app/view/update_delete_food_tracker_ui.dart';
import 'package:flutter_food_tracker_app/models/food.dart';

class ShowAllFoodTrackerUi extends StatefulWidget {
  const ShowAllFoodTrackerUi({super.key});

  @override
  State<ShowAllFoodTrackerUi> createState() =>
      _ShowAllFoodTrackerUiState();
}

class _ShowAllFoodTrackerUiState extends State<ShowAllFoodTrackerUi> {
  List<Food> foods = [];
  bool isLoading = true;

  // -------- LOAD DATA --------
  Future<void> loadFoods() async {
    try {
      final service = SupabaseService();
      final data = await service.getFoods();

      setState(() {
        foods = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 232, 43, 18),
        title: const Text(
          'Food Tracker',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // -------- ADD BUTTON --------
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 232, 43, 18),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFoodTrackerUi(),
            ),
          ).then((value) {
            loadFoods();
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          const SizedBox(height: 40),

          Image.asset(
            'assets/images/hot-pot.png',
            width: 150,
            height: 150,
          ),

          const SizedBox(height: 20),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : foods.isEmpty
                    ? const Center(child: Text('ไม่มีข้อมูลอาหาร'))
                    : ListView.builder(
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          final food = foods[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 35,
                            ),
                            child: ListTile(
                              // -------- IMAGE --------
                              leading: (food.foodImageUrl != null &&
                                      food.foodImageUrl!.isNotEmpty)
                                  ? Image.network(
                                      food.foodImageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,

                                      // 🔥 กันรูปพัง
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/hot-pot.png',
                                          width: 50,
                                          height: 50,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/hot-pot.png',
                                      width: 50,
                                      height: 50,
                                    ),

                              // -------- TITLE --------
                              title: Text(
                                'เมนู: ${food.foodName ?? '-'}',
                              ),

                              // -------- SUBTITLE --------
                              subtitle: Text(
                                'มื้อ: ${food.foodMeal ?? '-'} | ราคา: ${food.foodPrice ?? 0} บาท',
                              ),

                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.fastfood,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateDeleteFoodTrackerUi(food: food),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      loadFoods(); // โหลดข้อมูลใหม่ถ้าอัพเดทหรือลบสำเร็จ
                                    }
                                  });
                                },
                              ),

                              tileColor: index % 2 == 0
                                  ? const Color.fromARGB(255, 232, 43, 18)
                                  : const Color.fromARGB(255, 144, 238, 144),

                              contentPadding: const EdgeInsets.all(10),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}