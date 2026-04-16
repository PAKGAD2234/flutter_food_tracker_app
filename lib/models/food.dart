import 'package:intl/intl.dart';

class Food {
  String? id;
  String? foodName;
  String? foodMeal;
  int? foodPerson;
  double? foodPrice;
  DateTime? foodDate;
  String? foodImageUrl;
  DateTime? createdAt;

  Food({
    this.id,
    this.foodName,
    this.foodMeal,
    this.foodPerson,
    this.foodPrice,
    this.foodDate,
    this.foodImageUrl,
    this.createdAt,
  });

  // แปลงจาก JSON → Object
  factory Food.fromJson(Map<String, dynamic> json) {
    String? parseString(Map<String, dynamic> data, List<String> keys) {
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) {
          return data[key].toString();
        }
      }
      return null;
    }

    num? parseNum(Map<String, dynamic> data, List<String> keys) {
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) {
          final value = data[key];
          if (value is num) return value;
          final parsed = num.tryParse(value.toString());
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    final dateString = parseString(json, ['foodDate', 'fooddate']);
    final createdAtString = parseString(json, ['created_at', 'createdAt']);

    return Food(
      id: parseString(json, ['id']),
      foodName: parseString(json, ['foodName', 'foodname']),
      foodMeal: parseString(json, ['foodMeal', 'foodmeal']),
      foodPerson: parseNum(json, ['foodPerson', 'foodperson'])?.toInt(),
      foodPrice: parseNum(json, ['foodPrice', 'foodprice'])?.toDouble(),
      foodDate: dateString != null ? DateTime.tryParse(dateString) : null,
      foodImageUrl: (() {
        final rawUrl = parseString(json, ['foodImageUrl', 'foodimageurl', 'food_image_url', 'foodlmageUrl']);
        if (rawUrl == null || rawUrl.isEmpty) return null;
        if (rawUrl.startsWith('http')) return rawUrl;
        return 'https://dmrmyvgqrjbzhdyqacqv.supabase.co/storage/v1/object/public/food_tracker_bk/$rawUrl';
      })(),
      createdAt: createdAtString != null ? DateTime.tryParse(createdAtString) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (foodName != null) data['foodName'] = foodName;
    if (foodMeal != null) data['foodMeal'] = foodMeal;
    if (foodPerson != null) data['foodPerson'] = foodPerson;
    if (foodPrice != null) data['foodPrice'] = foodPrice;
    if (foodDate != null) data['foodDate'] = DateFormat('yyyy-MM-dd').format(foodDate!);
    if (foodImageUrl != null && foodImageUrl!.isNotEmpty) data['foodlmageUrl'] = foodImageUrl; // 🔥 ใช้ชื่อฟิลด์จริง
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();

    return data;
  }
}
