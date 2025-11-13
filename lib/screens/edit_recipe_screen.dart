import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/recipe/recipe_state.dart';
import '../models/recipe.dart';
import '../cubits/recipe/recipe_cubit.dart';
import '../utils/validators.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _ingredients;
  late final TextEditingController _steps;
  late final TextEditingController _category;
  late final TextEditingController _videoUrl;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.recipe.title);
    _ingredients = TextEditingController(text: widget.recipe.ingredients.join(', '));
    _steps = TextEditingController(text: widget.recipe.steps.join(', '));
    _category = TextEditingController(text: widget.recipe.category);
    _videoUrl = TextEditingController(text: widget.recipe.videoUrl);
  }

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
    context.read<RecipeCubit>().updateRecipe(widget.recipe.id, {
      'title': _title.text.trim(),
      'ingredients': _ingredients.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'steps': _steps.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'category': _category.text.trim(),
      'videoUrl': _videoUrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeCubit, RecipeState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (!state.loading && state.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Recipe')),
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
                    decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _steps,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Steps (comma separated)'),
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
                        : const Text('Save Changes'),
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



