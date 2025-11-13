import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_book/screens/login_screen.dart';

import '../cubits/auth/auth_state.dart';
import '../models/recipe.dart';
import '../cubits/auth/auth_cubit.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_item.dart';
import 'edit_recipe_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RecipeService _service = RecipeService();
  List<Recipe> _recipes = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthCubit>().state.firebaseUser?.uid;
    if (uid == null) return;
    final list = await _service.listUserRecipes(uid);
    setState(() {
      _recipes = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.profile;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await context.read<AuthCubit>().logout();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen(),),(route) => false,);
                   }
                },
              )
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 36, child: Icon(Icons.person)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?.name ?? '', style: Theme.of(context).textTheme.titleMedium),
                              Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('My Recipes', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final r in _recipes)
                      RecipeItem(
                        recipe: r,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => EditRecipeScreen(recipe: r)),
                          );
                          if (mounted) _load();
                        },
                      ),
                  ],
                ),
        );
      },
    );
  }
}


