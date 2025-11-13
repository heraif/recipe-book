import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeService _service = RecipeService();

  // 💡 متغير للاحتفاظ بالاشتراك الحالي في Stream
  StreamSubscription<List<Recipe>>? _recipeStreamSubscription;

  RecipeCubit() : super(const RecipeState()) {
    // 💡 الاشتراك المبدئي في الـ Stream عند إنشاء الـ Cubit
    _subscribeToCategoryStream(state.category);
  }

  // ❌ تم حذف التجاوز الخاطئ لـ @override Stream<List<Recipe>> get stream

  // 💡 دالة خاصة للاشتراك في Stream عند تغيير الفئة
  void _subscribeToCategoryStream(String category) {
    // 1. إلغاء أي اشتراك قديم لتجنب تسرب الذاكرة
    _recipeStreamSubscription?.cancel();

    // 2. الاشتراك في الـ Stream الجديد وإصدار الحالة (Emit) عند وصول بيانات
    _recipeStreamSubscription = _service.listByCategoryStream(category).listen(
            (latestRecipes) {
          // يتم إصدار حالة جديدة عند ورود أي بيانات جديدة من الـ Stream
          emit(state.copyWith(recipes: latestRecipes, error: null, loading: false));
        },
        onError: (e) {
          // معالجة خطأ الـ Stream
          emit(state.copyWith(error: e.toString(), loading: false));
        }
    );
  }

  // 💡 يجب إلغاء الاشتراك عند إغلاق الـ Cubit لمنع تسرب الذاكرة
  @override
  Future<void> close() {
    _recipeStreamSubscription?.cancel();
    return super.close();
  }

  void setCategory(String cat) {
    // عند تغيير الفئة، نغير الحالة ونعيد الاشتراك
    emit(state.copyWith(category: cat, error: null, loading: true));
    _subscribeToCategoryStream(cat);
  }

  // ❌ تم حذف الدالة updateRecipesFromStream لأنها أصبحت جزءاً من دالة الـ listen
  // void updateRecipesFromStream(List<Recipe> latest) { ... }

  Future<void> search(String query) async {
    // ... (منطق البحث يبقى كما هو)
    if (query.trim().isEmpty) {
      // 💡 عند إلغاء البحث، يجب أن نعيد الاشتراك في الـ Stream لعرض كل الوصفات
      // (إلا إذا كنت تريد عرض قائمة فارغة، لكن المنطقي هو العودة للـ Stream)
      emit(state.copyWith(recipes: [], error: null));
      _subscribeToCategoryStream(state.category); // إعادة تفعيل الـ Stream
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    try {
      // 💡 يتم تشغيل البحث (قد يكون هذا البحث يدوياً وليس عبر Stream)
      final results = await _service.search(query, state.category);
      emit(state.copyWith(recipes: results, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clearSearch() {
    emit(state.copyWith(recipes: [], error: null));
    _subscribeToCategoryStream(state.category); // 💡 إعادة تفعيل الـ Stream
  }

  Future<void> addRecipe(Recipe recipe) async {
    // ... (باقي الكود لعملية الإضافة)
    emit(state.copyWith(loading: true, error: null));
    try {
      await _service.addRecipe(recipe);
      // لا تحتاج لإصدار قائمة جديدة، لأن الـ Stream سيتولى التحديث تلقائياً!
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }




  Future<void> updateRecipe(String id, Map<String, Object?> updates) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _service.updateRecipe(id, updates);
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> deleteRecipe(String id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _service.deleteRecipe(id);
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}

