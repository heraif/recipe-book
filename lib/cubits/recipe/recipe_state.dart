import 'package:equatable/equatable.dart';

import '../../models/recipe.dart';

class RecipeState extends Equatable {
  final String category;
  final List<Recipe> recipes;
  final bool loading;
  final String? error;

  const RecipeState({
    this.category = 'All',
    this.recipes = const [],
    this.loading = false,
    this.error,
  });

  RecipeState copyWith({
    String? category,
    List<Recipe>? recipes,
    bool? loading,
    String? error,
  }) {
    return RecipeState(
      category: category ?? this.category,
      recipes: recipes ?? this.recipes,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [category, recipes, loading, error];
}

