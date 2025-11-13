import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/auth/auth_state.dart';
import '../cubits/recipe/recipe_state.dart';
import '../models/recipe.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/recipe/recipe_cubit.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool _isDeleting = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final uid = authState.firebaseUser?.uid;
        final isOwner = uid == widget.recipe.ownerId;
        return BlocListener<RecipeCubit, RecipeState>(
          listenWhen: (previous, current) => _isDeleting && previous.loading && !current.loading,
          listener: (context, state) {
            if (_isDeleting) {
              _isDeleting = false;
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe deleted')));
                Navigator.of(context).pop();
              }
            }
          },
          child: BlocBuilder<RecipeCubit, RecipeState>(
            builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.recipe.title),
                actions: [
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditRecipeScreen(recipe: widget.recipe)),
                      ),
                    ),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Recipe'),
                            content: const Text('Are you sure you want to delete this recipe?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          setState(() => _isDeleting = true);
                          context.read<RecipeCubit>().deleteRecipe(widget.recipe.id);
                        }
                      },
                    )
                ],
              ),
              body: ListView(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.recipe.imageUrl.isEmpty
                        ? const ColoredBox(color: Colors.black12)
                        : CachedNetworkImage(imageUrl: widget.recipe.imageUrl, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.recipe.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(label: Text(widget.recipe.category)),
                            const SizedBox(width: 8),
                            Text('By ${widget.recipe.ownerName}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Text(widget.recipe.ingredients.join('\n')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Steps', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Text(widget.recipe.steps.join('\n')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.recipe.videoUrl.isNotEmpty)
                          InkWell(
                            onTap: () => _openUrl(widget.recipe.videoUrl),
                            child: Text(
                              widget.recipe.videoUrl,
                              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            );
            },
          ),
        );
      },
    );
  }
}



