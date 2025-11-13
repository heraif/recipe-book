import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../cubits/auth/auth_state.dart';
import '../cubits/recipe/recipe_state.dart';
import '../models/recipe.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/recipe/recipe_cubit.dart';
import '../widgets/recipe_item.dart';
import 'add_recipe_screen.dart';
import 'profile_screen.dart';
import 'recipe_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _search = TextEditingController();
  final List<String> _categories = ['All'];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _search.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  bool _listEquals(List<String> a, List<String> b) {
    return const ListEquality().equals(a, b);
  }

  void _updateTabsFromData(List<Recipe> recipes) {
    final cats = {'All', ...recipes.map((e) => e.category)}.toList()..sort();
    if (cats.length != _categories.length || !_listEquals(cats, _categories)) {
      _categories
        ..clear()
        ..addAll(cats);

      final oldIndex = _tabController?.index ?? 0;
      _tabController?.dispose();

      _tabController = TabController(length: _categories.length, vsync: this);
      _tabController!.index = oldIndex.clamp(0, _categories.length - 1);
      setState(() {}); // نحتاج إعادة بناء الشاشة مع TabController الجديد
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocConsumer<RecipeCubit, RecipeState>(
          listener: (context, recipeState) {
            // تحديث Tabs بعد الإطار الأول بعد تحميل البيانات
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateTabsFromData(recipeState.recipes);
            });
          },
          builder: (context, recipeState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Recipe Book'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  )
                ],
                bottom: _tabController == null
                    ? null
                    : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _categories.map((c) => Tab(text: c)).toList(),
                  onTap: (i) {
                    context.read<RecipeCubit>().setCategory(_categories[i]);
                    _search.clear();
                  },
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (authState.firebaseUser == null) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: 'Search by recipe name',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            FocusScope.of(context).unfocus();
                            context.read<RecipeCubit>().clearSearch();
                            setState(() {});
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onSubmitted: (_) {
                        if (_search.text.trim().isNotEmpty) {
                          context.read<RecipeCubit>().search(_search.text.trim());
                        }
                      },
                      onChanged: (_) {
                        setState(() {});
                        if (_search.text.trim().isEmpty) {
                          context.read<RecipeCubit>().clearSearch();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<RecipeCubit, RecipeState>(
                      builder: (context, state) {
                        final listToDisplay = _search.text.trim().isEmpty
                            ? state.recipes
                            : state.recipes;

                        if (state.loading && _search.text.trim().isNotEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (listToDisplay.isEmpty) {
                          return const Center(child: Text('No recipes found'));
                        }

                        return ListView.builder(
                          itemCount: listToDisplay.length,
                          itemBuilder: (context, index) {
                            final item = listToDisplay[index];
                            return RecipeItem(
                              recipe: item,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailsScreen(recipe: item),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
