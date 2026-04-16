import 'package:image_picker/image_picker.dart';
import 'package:flutter_food_tracker_app/models/food.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // -------- GET ALL FOOD --------
  Future<List<Food>> getFoods() async {
    final data = await supabase.from('food_tracker_tb').select('*');

    print('RAW DATA FROM SUPABASE: $data'); // 🔥 debug เพิ่มกลับ

    return (data as List)
        .map((food) => Food.fromJson(food))
        .toList();
  }

  // -------- UPLOAD FILE --------
  Future<String> uploadFile(XFile file) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}-${file.name}';

      final bytes = await file.readAsBytes();

      await supabase.storage.from('food_tracker_bk').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final dynamic url =
          supabase.storage.from('food_tracker_bk').getPublicUrl(fileName);

      if (url is String) {
        return url;
      }
      if (url is Map<String, dynamic> && url['publicUrl'] != null) {
        return url['publicUrl'] as String;
      }
      return url.toString();
    } catch (error) {
      rethrow;
    }
  }

  // -------- INSERT FOOD --------
  Future insertFood(Food food) async {
    final payload = food.toJson();

    try {
      await supabase.from('food_tracker_tb').insert(payload);
    } catch (error) {
      if (error is PostgrestException &&
          error.code == 'PGRST204' &&
          payload.containsKey('foodlmageUrl')) {
        final fallbackPayload = Map<String, dynamic>.from(payload);
        fallbackPayload['foodimageurl'] = fallbackPayload.remove('foodlmageUrl');
        await supabase.from('food_tracker_tb').insert(fallbackPayload);
      } else {
        rethrow;
      }
    }
  }

  // -------- DELETE FILE --------
  Future deleteFile(String fileUrl) async {
    final fileName = fileUrl.split('/').last;

    await supabase.storage.from('food_tracker_bk').remove([fileName]);
  }

  // -------- UPDATE FOOD --------
  Future updateFood(String id, Food food) async {
    final payload = food.toJson();

    try {
      await supabase
          .from('food_tracker_tb')
          .update(payload)
          .eq('id', id);
    } catch (error) {
      if (error is PostgrestException &&
          error.code == 'PGRST204' &&
          payload.containsKey('foodlmageUrl')) {
        final fallbackPayload = Map<String, dynamic>.from(payload);
        fallbackPayload['foodimageurl'] = fallbackPayload.remove('foodlmageUrl');
        await supabase
            .from('food_tracker_tb')
            .update(fallbackPayload)
            .eq('id', id);
      } else {
        rethrow;
      }
    }
  }

  // -------- DELETE FOOD --------
  Future deleteFood(String id) async {
    await supabase.from('food_tracker_tb').delete().eq('id', id);
  }
}