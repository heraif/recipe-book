import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeItem extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeItem({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: 120,
              child: recipe.imageUrl.isEmpty
                  ? const ColoredBox(color: Colors.black12)
                  : CachedNetworkImage(
                      imageUrl: recipe.imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(recipe.category, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



