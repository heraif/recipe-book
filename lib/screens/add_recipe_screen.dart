import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/recipe/recipe_state.dart';
import '../models/recipe.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/recipe/recipe_cubit.dart';
import '../utils/validators.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  final _category = TextEditingController();
  final _videoUrl = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _category.dispose();
    _videoUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthCubit>().state;
    final user = authState.firebaseUser;
    if (user == null) return;

    final recipe = Recipe(
      id: '',
      title: _title.text.trim(),
      ingredients: _ingredients.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      steps: _steps.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      category: _category.text.trim(),
      imageUrl: '',
      videoUrl: _videoUrl.text.trim(),
      ownerId: user.uid,
      ownerName: authState.profile?.name ?? '',
    );

    context.read<RecipeCubit>().addRecipe(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeCubit, RecipeState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (!state.loading && state.error == null && _title.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe added')));
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Add Recipe')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => Validators.requiredField(v, label: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ingredients,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients (comma separated)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _steps,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Steps (comma separated)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => Validators.requiredField(v, label: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _videoUrl,
                    decoration: const InputDecoration(labelText: 'YouTube URL'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: state.loading ? null : _save,
                    child: state.loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}



